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

describe Image do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :uid => "value for uid",
    }
  end

  it { should have_many :platform_versions }
  it { should have_many :instances }
  it { should have_many :image_services }
  it { should have_many :services }
  it { should have_many :cloud_images }

  it "should create a new instance given valid attributes" do
    Image.create!(@valid_attributes)
  end

  it "should have a name attribute" do
    Image.new.should respond_to(:name)
  end

  describe "needs_storage_volume?" do
    before(:each) do
      @image = Factory.build(:image)
    end

    it "should be true if the storage_volume_capacity is set" do
      @image.storage_volume_capacity = '1'
      @image.needs_storage_volume?.should be_true
    end

    it "should be false if the storage_volume_capacity is not set" do
      @image.storage_volume_capacity = nil
      @image.needs_storage_volume?.should_not be_true
    end


  end

  describe "cloud_id" do
    before(:each) do
      @image = Factory.build(:image)
      @user = Factory.build(:user)
      @hardware_profile = 'm1-small'
      @cloud = mock('cloud')
      @cloud.stub!(:architecture).and_return('architecture')
      @cloud.stub!(:name).and_return('name')
      @cloud.stub!(:region).and_return('region')
      @user.stub!(:cloud).and_return(@cloud)
    end

    it "should lookup architecture from hardware profile" do
      @cloud.should_receive(:architecture).with(@hardware_profile).and_return('i386')
      @image.cloud_id(@hardware_profile, @user)
    end

    it "should lookup name from cloud" do
      @cloud.should_receive(:name).and_return('name')
      @image.cloud_id(@hardware_profile, @user)
    end

    it "should lookup region from cloud" do
      @cloud.should_receive(:region).and_return('region')
      @image.cloud_id(@hardware_profile, @user)
    end

    it "should return nil if cloud_image not found" do
      @image.cloud_id(@hardware_profile, @user).should be_nil
    end

    it "should return cloud_id if cloud_image found" do
      cloud_image = mock('cloud_image', :cloud_id => 'ami-123')
      @image.stub!(:cloud_images).and_return(CloudImage)
      CloudImage.should_receive(:find).with(:first, :conditions => {
                                              :cloud => 'name',
                                              :region => 'region',
                                              :architecture => 'architecture'}).and_return(cloud_image)
      @image.cloud_id(@hardware_profile, @user).should == 'ami-123'
    end
  end
end
