#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

require 'spec_helper'


describe Certificate do
  class Certificate
    #so we can clear between tests
    class << self;attr_writer :ca_certificate, :client_certificate;end 
  end
  
  before(:each) do
    @valid_attributes = {
      :cert_type => "value for type",
      :certificate => "value for certificate",
      :keypair => "value for keypair",
      :certifiable_id => 1,
      :certifiable_type => "Certificate"
    }
    APP_CONFIG[:certificate_password] = nil
  end

  it { should belong_to :certifiable }
  it { should validate_presence_of :cert_type }
  it { should validate_presence_of :certificate }
  it { should validate_presence_of :keypair }
  
  it "should create a new instance given valid attributes" do
    Certificate.create!(@valid_attributes)
  end


  describe "ca_certificate" do
    before(:each) do
      Certificate.ca_certificate = nil
    end
    
    it "should return an existing ca cert" do
      cert = Factory.build(:ca_certificate)
      Certificate.should_receive(:find).and_return(cert)
      Certificate.ca_certificate.should == cert
    end

    it "should create a ca if none found" do
      Certificate.should_receive(:create)
      Certificate.ca_certificate
    end

    
  end

  describe "client_certificate" do
    before(:each) do
      Certificate.client_certificate = nil
    end
    
    it "should return an existing ca cert" do
      cert = Factory.build(:client_certificate)
      Certificate.should_receive(:find).and_return(cert)
      Certificate.client_certificate.should == cert
    end

    it "should create a client if none found" do
      # generate the ca before we mock
      Certificate.ca_certificate
      Certificate.should_receive(:create)
      Certificate.client_certificate
    end
    
  end

  describe "generate_server_certificate" do
    before(:each) do
      @instance = Instance.new
      @instance.stub!(:id).and_return(777)
      # go ahead and create the CA so it doesn't trip the expectations
      Certificate.ca_certificate
    end
    
    it "should generate a cert" do
      Certificate.should_receive(:create)
      Certificate.generate_server_certificate(@instance)
    end
    
    it "should associate the cert with the certifiable record" do
      cert = Certificate.generate_server_certificate(@instance)
      cert.certifiable_id.should == @instance.id
      cert.certifiable_type.should == @instance.class.name
    end

    it "should be server cert type" do
      cert = Certificate.generate_server_certificate(@instance)
      cert.cert_type.should == Certificate::SERVER_TYPE
    end
    
    it "should use the certifiable id as the serial" do
      cert = Certificate.generate_server_certificate(@instance)
      cert.to_x509_certificate.serial.should == @instance.id
      
    end
  end

  describe "keypair encyption/decryption" do
    context "when a password is set" do
      before(:each) do
        @password = APP_CONFIG[:certificate_password] = 'abcd'
        @certificate = Certificate.new
        @keypair = OpenSSL::PKey::RSA.new 1024
        @pem = @keypair.to_pem
        @enc_pem = @keypair.export OpenSSL::Cipher::DES.new(:EDE3, :CBC), @password
      end

      it "should encrypt the keypair on write" do
        OpenSSL::PKey::RSA.stub_chain(:new, :export).and_return(@enc_pem)
        @certificate.should_receive(:write_attribute).with("keypair", @enc_pem)
        @certificate.keypair = @pem
      end

      it "should decrypt the keypair on read" do
        @certificate.stub!(:read_attribute).and_return(@enc_pem)
        OpenSSL::PKey::RSA.should_receive(:new).with(@enc_pem, @password)
        @certificate.keypair
      end
    end
    
    context "when a password is not set" do
      before(:each) do
        APP_CONFIG[:certificate_password] = nil
        @certificate = Certificate.new
        OpenSSL::PKey::RSA.should_not_receive(:new)
      end

      it "should not encrypt the keypair on write" do
        @certificate.keypair = 'stuff'
      end

      it "should not decrypt the keypair on read" do
        @certificate.keypair
      end
    end
    
  end

  describe "to_public_pem_file" do
    before(:each) do
      @cert = Certificate.ca_certificate
      @path = Rails.root + "/tmp/cert_#{@cert.id}.pem"
      FileUtils.rm_f(@path)
    end
    
    it "should create a file with the certificate in pem format" do
      @cert.to_public_pem_file
      File.exists?(@path).should be_true
      File.read(@path).should == @cert.certificate
    end

    it "should return the pathname" do
      @cert.to_public_pem_file.should == @path
    end

    it "should not write the file if it already exists" do
      File.should_receive(:exists?).with(@path).and_return(true)
      File.should_not_receive(:open)
      @cert.to_public_pem_file
    end
  end
end
