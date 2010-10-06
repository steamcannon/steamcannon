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

describe User do
  before(:each) do
    @valid_attributes = {
      :email => "test_user@mailinator.com",
      :password => "test_password",
      :password_confirmation => "test_password"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end

  it "should have a cloud_username attribute" do
    User.new.should respond_to(:cloud_username)
  end

  it "should have a cloud password attribute" do
    User.new.should respond_to(:cloud_password)
  end

  it "should encrypt the cloud password attribute before save" do
    u = User.create!(@valid_attributes)
    u.stub!(:validate_cloud_credentials)
    u.cloud_password = "steamcannon"
    Certificate.should_receive :encrypt
    u.save
  end

  it "should save the encrypted cloud password" do
    u = User.create!(@valid_attributes)
    u.stub!(:validate_cloud_credentials)
    u.cloud_password = "steamcannon"
    u.should_receive :crypted_cloud_password=
    u.save
  end

  it "should not save the encrypted cloud password if it hasn't changed" do
    u = User.create!(@valid_attributes)
    u.email = "somethingelse@steamcannon.org"
    u.should_not_receive :crypted_cloud_password=
    u.save
  end

  it "should provide an obfuscated version of the cloud password" do
    u = User.create!(@valid_attributes)
    u.should respond_to :obfuscated_cloud_password
  end

  it "should completely obfuscate any cloud password with fewer than 6 characters" do
    u = User.create!(@valid_attributes)
    u.cloud_password = "12345"
    u.obfuscated_cloud_password.should == "******"
  end

  it "should handle cloud passwords with fewer than 4 characters" do
    u = User.create!(@valid_attributes)
    u.cloud_password = "123"
    u.obfuscated_cloud_password.should == "******"
  end

  it "should obfuscate all but the last for characters of any cloud password with more than 6 characters" do
    u = User.create!(@valid_attributes)
    u.cloud_password = "1234567890"
    u.obfuscated_cloud_password.should == "******7890"
  end

  it "should have a cloud object" do
    User.new.should respond_to(:cloud)
  end

  it "should have many environments" do
    User.new.should respond_to(:environments)
  end

  it "should have an SSH key name attribute" do
    User.new.should respond_to(:ssh_key_name)
    User.new.should respond_to(:ssh_key_name=)
  end

  it "should have no default SSH key name attribute" do
    User.new.ssh_key_name.should be_blank
  end

  it "should have many artifacts" do
    User.new.should respond_to(:artifacts)
  end

  it "should pass cloud credentials through to cloud object" do
    user = User.new(:cloud_username => 'user', :cloud_password => 'pass')
    Cloud::Deltacloud.should_receive(:new).with('user', 'pass')
    user.cloud
  end

  it "should not allow mass assignment of the superuser column" do
    user = Factory.build(:user)
    user.update_attributes(:superuser => true)
    user.superuser.should == false
  end

  context "visible_to_user named_scope" do
    before(:each) do
      @superuser = Factory(:superuser)
      @account_user = Factory(:user)
    end

    it "should include all users for a superuser" do
      User.visible_to_user(@superuser).should == [@superuser, @account_user]
    end

    it "should only include the given user for an account_user" do
      User.visible_to_user(@account_user).should == [@account_user]
    end
  end

  context "validate_cloud_credentials" do
    before(:each) do
      @user = Factory(:user)
      @cloud = mock('cloud')
      @user.stub!(:cloud).and_return(@cloud)
    end

    it "should validate if cloud_username has changed" do
      @user.cloud_username = 'username'
      @cloud.should_receive(:valid_credentials?)
      @user.validate_cloud_credentials
    end

    it "should validate if cloud_password has changed" do
      @user.cloud_password = 'password'
      @cloud.should_receive(:valid_credentials?)
      @user.validate_cloud_credentials
    end

    it "shouldn't validate if cloud_username and cloud_password haven't changed" do
      @cloud.should_not_receive(:valid_credentials?)
      @user.validate_cloud_credentials
    end

    it "should add an error if invalid" do
      @user.cloud_username = 'username'
      @cloud.should_receive(:valid_credentials?).and_return(false)
      @user.validate_cloud_credentials
      @user.errors.size.should be(1)
    end

    it "should not add an error if valid" do
      @user.cloud_username = 'username'
      @cloud.should_receive(:valid_credentials?).and_return(true)
      @user.validate_cloud_credentials
      @user.errors.size.should be(0)
    end
  end

  context "validate_ssh_key_name" do
    before(:each) do
      @user = Factory(:user)
      @cloud = mock('cloud')
      @user.stub!(:cloud).and_return(@cloud)
    end

    it "should validate if ssh_key_name has changed" do
      @user.ssh_key_name = 'key_name'
      @cloud.should_receive(:valid_key_name?)
      @user.validate_ssh_key_name
    end

    it "shouldn't validate if ssh_key_name hasn't changed" do
      @cloud.should_not_receive(:valid_key_name?)
      @user.validate_ssh_key_name
    end

    it "shouldn't validate if ssh_key_name is blank" do
      @user.ssh_key_name = ''
      @cloud.should_not_receive(:valid_key_name?)
      @user.validate_ssh_key_name
    end

    it "should add an error if invalid" do
      @user.ssh_key_name = 'key_name'
      @cloud.should_receive(:valid_key_name?).and_return(false)
      @user.validate_ssh_key_name
      @user.errors.size.should be(1)
    end

    it "should not add an error if valid" do
      @user.ssh_key_name = 'key_name'
      @cloud.should_receive(:valid_key_name?).and_return(true)
      @user.validate_ssh_key_name
      @user.errors.size.should be(0)
    end
  end
end
