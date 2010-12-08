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

describe Organization do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
    @organization = Factory(:organization)
  end

  it { should have_many :users }
  it { should have_many :account_requests }

  it "should create a new instance given valid attributes" do
    Organization.create!(@valid_attributes)
  end

  it "should have a cloud_username attribute" do
    @organization.should respond_to(:cloud_username)
  end

  it "should have a cloud password attribute" do
    @organization.should respond_to(:cloud_password)
  end

  it "should encrypt the cloud password attribute before save" do
    @organization.stub!(:validate_cloud_credentials)
    @organization.cloud_password = "steamcannon"
    Certificate.should_receive :encrypt
    @organization.save
  end

  it "should save the encrypted cloud password" do
    @organization.stub!(:validate_cloud_credentials)
    @organization.cloud_password = "steamcannon"
    @organization.should_receive :crypted_cloud_password=
    @organization.save
  end

  it "should not save the encrypted cloud password if it hasn't changed" do
    @organization.name = "somethingelse"
    @organization.should_not_receive :crypted_cloud_password=
    @organization.save
  end

  it "should provide an obfuscated version of the cloud password" do
    @organization.should respond_to :obfuscated_cloud_password
  end

  it "should completely obfuscate any cloud password with fewer than 6 characters" do
    @organization.cloud_password = "12345"
    @organization.obfuscated_cloud_password.should == "******"
  end

  it "should handle cloud passwords with fewer than 4 characters" do
    @organization.cloud_password = "123"
    @organization.obfuscated_cloud_password.should == "******"
  end

  it "should obfuscate all but the last for characters of any cloud password with more than 6 characters" do
    @organization.cloud_password = "1234567890"
    @organization.obfuscated_cloud_password.should == "******7890"
  end

  it "should have a cloud object" do
    @organization.should respond_to(:cloud)
  end

  it "should pass cloud credentials through to cloud object" do
    @organization.cloud_username = 'user'
    @organization.cloud_password = 'password'
    Cloud::Deltacloud.should_receive(:new).with('user', 'password')
    @organization.cloud
  end

  context "validate_cloud_credentials" do
    before(:each) do
      @cloud = mock('cloud')
      @organization.stub!(:cloud).and_return(@cloud)
    end

    it "should validate on save" do
      @organization.cloud_username = 'username'
      @organization.should_receive(:validate_cloud_credentials)
      @organization.save
    end

    it "should validate if cloud_username has changed" do
      @organization.cloud_username = 'username'
      @cloud.should_receive(:valid_credentials?)
      @organization.send(:validate_cloud_credentials)
    end

    it "should validate if cloud_password has changed" do
      @organization.cloud_password = 'password'
      @cloud.should_receive(:valid_credentials?)
      @organization.send(:validate_cloud_credentials)
    end

    it "shouldn't validate if cloud_username and cloud_password haven't changed" do
      @cloud.should_not_receive(:valid_credentials?)
      @organization.send(:validate_cloud_credentials)
    end

    it "should add an error if invalid" do
      @organization.cloud_username = 'username'
      @cloud.should_receive(:valid_credentials?).and_return(false)
      @organization.send(:validate_cloud_credentials)
      @organization.errors.size.should be(1)
    end

    it "should not add an error if valid" do
      @organization.cloud_username = 'username'
      @cloud.should_receive(:valid_credentials?).and_return(true)
      @organization.send(:validate_cloud_credentials)
      @organization.errors.size.should be(0)
    end
  end
end
