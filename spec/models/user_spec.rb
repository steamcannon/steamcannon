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

  it { should belong_to :organization }
  it { should have_many :environments }
  it { should have_many :artifacts }
  
  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end

  it "should have an SSH key name attribute" do
    User.new.should respond_to(:ssh_key_name)
    User.new.should respond_to(:ssh_key_name=)
  end

  it "should have no default SSH key name attribute" do
    User.new.ssh_key_name.should be_blank
  end

  it "should not allow mass assignment of the superuser column" do
    user = Factory.build(:user)
    user.update_attributes(:superuser => true)
    user.superuser.should == false
  end

  it "should create an organization if none given" do
    user = User.create!(@valid_attributes)
    user.organization.should_not be_nil
    user.organization_admin?.should be(true)
  end

  it "should not create an organization if given" do
    org = Factory(:organization)
    user = User.create!(@valid_attributes.merge(:organization => org))
    user.organization.should == org
    user.organization_admin?.should be(false)
  end

  it "should not allow mass assignment of the organization_admin column" do
    user = Factory.build(:user)
    user.update_attributes(:organization_admin => true)
    user.organization_admin?.should == false
  end

  context "visible_to_user named_scope" do
    before(:each) do
      @superuser = Factory(:superuser)
      @account_user = Factory(:user)
    end

    it "should include all users for a superuser" do
      Set.new(User.visible_to_user(@superuser)).should == Set.new([@superuser, @account_user])
    end

    it "should only include the given user for an account_user" do
      User.visible_to_user(@account_user).should == [@account_user]
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
