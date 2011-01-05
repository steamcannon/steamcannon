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
  it { should have_many :cloud_profiles }
  it { should have_many(:environments).through(:users) }
  it { should have_many(:artifacts).through(:users) }
  
  it "should create a new instance given valid attributes" do
    Organization.create!(@valid_attributes)
  end

  describe "has_cloud_profiles?" do
    it "should return true if the org has at least one saved cloud profile" do
      @organization.cloud_profiles << Factory.build(:cloud_profile) 
      @organization.has_cloud_profiles?.should be_true
    end

    it "should return false if the org has no cloud profiles" do
      @organization.has_cloud_profiles?.should_not be_true
    end

    it "should return false if the org has one cloud profile and that cloud profile is not saved" do
      @organization.cloud_profiles << Factory.build(:cloud_profile, :name => nil) 
      @organization.has_cloud_profiles?.should_not be_true
    end

    it "should return true if the org has multiple cloud profiles and one cloud profile is not saved" do
      @organization.cloud_profiles << Factory.build(:cloud_profile) 
      @organization.cloud_profiles << Factory.build(:cloud_profile, :name => nil) 
      @organization.has_cloud_profiles?.should be_true
    end
  end
end
