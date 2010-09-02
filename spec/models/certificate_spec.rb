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
end
