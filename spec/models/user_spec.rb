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
  it { should have_many(:cloud_profiles).through(:organization) }
  
  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
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

end
