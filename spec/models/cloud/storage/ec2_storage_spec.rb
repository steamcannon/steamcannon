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
    @cloud_specific_hacks = mock('hacks')
    @cloud_profile = mock_model(CloudProfile,
                                :username => 'access_key',
                                :password => 'secret_access_key',
                                :cloud_specific_hacks => @cloud_specific_hacks)
    @ec2 = Cloud::Storage::Ec2Storage.new(@cloud_profile)
    @artifact_version = Factory.build(:artifact_version)
    @path = 'path/to/file.war'
    @ec2.stub!(:path).and_return(@path)
    @s3_object = mock('s3_object')
  end

  describe "write" do
    before(:each) do
      @file = mock('file')
      @artifact_version.stub_chain(:archive, :to_file).and_return(@file)
      @content_type = 'application/octet-stream'
      @artifact_version.stub!(:archive_content_type).and_return(@content_type)
      @ec2.stub!(:s3_object).and_return(@s3_object)
      @s3_object.stub!(:put)
    end

    it "should put new object from file" do
      @s3_object.should_receive(:put).with(@file, anything, anything)
      @ec2.write(@artifact_version)
    end

    it "should put new object with private permissions" do
      @s3_object.should_receive(:put).with(anything, 'private', anything)
      @ec2.write(@artifact_version)
    end

    it "should put new object with content_type from archive" do
      @s3_object.should_receive(:put).with(anything, anything, {'Content-Type' => @content_type})
      @ec2.write(@artifact_version)
    end
  end

  describe "delete" do
    it "should call delete on the s3 object" do
      @ec2.stub!(:s3_object).and_return(@s3_object)
      @s3_object.should_receive(:delete).and_return(true)
      @ec2.delete(@artifact_version)
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
      @ec2.public_url(@artifact_version)
    end
  end

  describe "bucket" do
    before(:each) do
      @bucket = Aws::S3::Bucket
      @bucket.stub!(:create)
      @cloud_specific_hacks.stub!(:unique_bucket_name).and_return('')
    end

    it "should create with correct prefix" do
      prefix = "SteamCannonArtifacts_"
      @cloud_specific_hacks.should_receive(:unique_bucket_name).with(prefix).and_return(prefix)
      @bucket.should_receive(:create).with(anything, /^#{prefix}/, anything, anything)
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

    it "should create a unique bucket name" do
      suffix = /unique_bucket_name$/
      @cloud_specific_hacks.should_receive(:unique_bucket_name).and_return('unique_bucket_name')
      @bucket.should_receive(:create).with(anything, suffix, anything, anything)
      @ec2.bucket
    end
  end

  describe "s3_object" do
    it "should return key from bucket" do
      bucket = mock('bucket')
      @ec2.should_receive(:bucket).and_return(bucket)
      bucket.should_receive(:key).with(@path).and_return('key')
      @ec2.s3_object(@artifact_version).should == 'key'
    end
  end
end
