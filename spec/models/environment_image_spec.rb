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

describe EnvironmentImage do
  before(:each) do
    @valid_attributes = {
      :environment_id => 1,
      :image_id => 1,
      :hardware_profile => "value for hardware_profile",
      :num_instances => 1
    }
  end

  it { should belong_to :environment }
  it { should belong_to :image }
  it { should have_many :storage_volumes }
  
  it "should create a new instance given valid attributes" do
    EnvironmentImage.create!(@valid_attributes)
  end

  describe 'start!' do
    before(:each) do
      @instance = Factory(:instance)
      @instance.stub_chain(:cloud_specific_hacks, :default_realm).and_return('def realm')
      Instance.stub!(:deploy!).and_return(@instance)
      @image = Factory(:image)
      @environment_image = Factory(:environment_image, :image => @image)
    end
    
    it "should be able to deploy an instance" do
      Instance.should_receive(:deploy!).and_return(@instance)
      @environment_image.start!(1)
    end
    
    context "storage volumes" do
      context "with an image that needs a volume" do
        before(:each) do
          @image.should_receive(:needs_storage_volume?).and_return(true)
          @storage_volume = mock(StorageVolume)
          @storage_volume.stub(:prepare).with(@instance) 
        end
        
        it "should create storage_volumes when the image needs one" do
          @environment_image.storage_volumes.should_receive(:create).and_return(@storage_volume)
          @environment_image.start!(1)
        end
        
        it "should not create a storage_volume if it already exists" do
          @environment_image.stub(:storage_volumes).and_return([@storage_volume])
          @environment_image.storage_volumes.should_not_receive(:create)
          @environment_image.start!(1)
        end

        it "should create a storage volume if one does not exist at the instance num index" do
          @environment_image.stub(:storage_volumes).and_return([@storage_volume])
          @environment_image.storage_volumes.should_receive(:create).and_return(@storage_volume)
          @environment_image.start!(2)
        end
        
        it "should trigger the storage_volume to prepare" do
          @storage_volume.should_receive(:prepare).with(@instance) 
          @environment_image.stub!(:storage_volumes).and_return([@storage_volume])
          @environment_image.start!(1)
        end
      end

      it "should not create storage_volumes if none needed" do
        @environment_image.start!(1)
        @environment_image.storage_volumes.first.should be_nil
      end


    end
  end
end
