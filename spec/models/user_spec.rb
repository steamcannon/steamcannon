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

  it "should have a cloud object" do
    User.new.should respond_to(:cloud)
  end

  it "should have many environments" do
    User.new.should respond_to(:environments)
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
end
