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

describe Cloud::Storage::Ec2Storage do
  before(:each) do
    @ec2 = Cloud::Storage::Ec2Storage.new('access_key', 'secret_access_key')
    @path = 'path/to/file.war'
    @s3_object = mock('s3_object')
  end

  describe "exists?" do
    it "should call exists? on the s3 object" do
      @ec2.stub!(:s3_object).and_return(@s3_object)
      @s3_object.should_receive(:exists?).and_return(true)
      @ec2.exists?(@path).should be(true)
    end
  end

  describe "to_file" do
    before(:each) do
      @ec2.stub!(:s3_object).and_return(@s3_object)
      @s3_object.stub!(:data).and_return('data')
      @tempfile = mock('tempfile')
      @tempfile.stub!(:write)
      @tempfile.stub!(:rewind)
      Tempfile.stub!(:new).and_return(@tempfile)
    end

    it "should create a temporary file" do
      Tempfile.should_receive(:new).with('file.war').and_return(@tempfile)
      @ec2.to_file(@path)
    end

    it "should write s3 object's data to temporary file" do
      @s3_object.should_receive(:data).and_return('data')
      @tempfile.should_receive(:write).with('data')
      @ec2.to_file(@path)
    end

    it "should rewind temporary file for reading" do
      @tempfile.should_receive(:rewind)
      @ec2.to_file(@path)
    end

    it "should return temporary file" do
      @ec2.to_file(@path).should == @tempfile
    end
  end

  describe "write" do
    before(:each) do
      @file = mock('file')
      @attachment = mock('attachment')
      @content_type = 'application/octet-stream'
      @attachment.stub!(:instance_read).with(:content_type).and_return(@content_type)
      @ec2.stub!(:s3_object).and_return(@s3_object)
      @s3_object.stub!(:put)
    end

    it "should put new object from file" do
      @s3_object.should_receive(:put).with(@file, anything, anything)
      @ec2.write(@path, @file, @attachment)
    end

    it "should put new object with private permissions" do
      @s3_object.should_receive(:put).with(anything, 'private', anything)
      @ec2.write(@path, @file, @attachment)
    end

    it "should put new object with content_type from attachment" do
      @attachment.should_receive(:instance_read).with(:content_type).and_return(@content_type)
      @s3_object.should_receive(:put).with(anything, anything, {'Content-Type' => @content_type})
      @ec2.write(@path, @file, @attachment)
    end
  end

  describe "delete" do
    it "should call delete on the s3 object" do
      @ec2.stub!(:s3_object).and_return(@s3_object)
      @s3_object.should_receive(:delete).and_return(true)
      @ec2.delete(@path)
    end
  end

  describe "public_url" do
    before(:each) do
      @sig = S3::Signature
      @ec2.stub!(:bucket_name).and_return('name')
    end

    it "should generate url for cloud credentials" do
      verify_signature_contains(:access_key => 'access_key',
                                :secret_access_key => 'secret_access_key')
    end

    it "should generate url for http get" do
      verify_signature_contains(:method => :get)
    end

    it "should generate url for correct bucket" do
      verify_signature_contains(:bucket => 'name')
    end

    it "should generate url for correct resource" do
      verify_signature_contains(:resource => @path)
    end

    def verify_signature_contains(options)
      @sig.should_receive(:generate_temporary_url).with(hash_including(options))
      @ec2.public_url(@path)
    end
  end

  describe "bucket" do
    before(:each) do
      @bucket = Aws::S3::Bucket
      @bucket.stub!(:create)
    end

    it "should create with correct prefix" do
      prefix = /^SteamCannonArtifacts_/
      @bucket.should_receive(:create).with(anything, prefix, anything, anything)
      @ec2.bucket
    end

    it "should create if it doesn't already exist" do
      @bucket.should_receive(:create).with(anything, anything, true, anything)
      @ec2.bucket
    end

    it "should create with private permissions" do
      @bucket.should_receive(:create).with(anything, anything, anything, 'private')
      @ec2.bucket
    end
  end

  describe "s3_object" do
    it "should return key from bucket" do
      bucket = mock('bucket')
      @ec2.should_receive(:bucket).and_return(bucket)
      bucket.should_receive(:key).with(@path).and_return('key')
      @ec2.s3_object(@path).should == 'key'
    end
  end
end
