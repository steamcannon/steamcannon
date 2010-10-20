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

describe Cloud::Base do
  before(:each) do
    @user = Factory.build(:user)
    @base = Cloud::Base.new(@user)
  end

  it "should have empty multicast_config" do
    instance = Factory.build(:instance)
    @base.multicast_config(instance).should be_empty
  end

  it "should have empty launch options" do
    instance = Factory.build(:instance)
    @base.launch_options(instance).should be_empty
  end

  describe "running_instances" do
    def mock_instance(attributes)
      image = mock('image', :name => 'image_name')
      mock('instance', attributes.merge(:image => image,
                                        :public_addresses => []))
    end

    before(:each) do
      @cloud = mock('cloud')
      @user.should_receive(:cloud).and_return(@cloud)
    end

    it "should retrieve from user's cloud" do
      @cloud.should_receive(:instances).and_return([])
      @base.running_instances
    end

    it "should filter out stopped" do
      started = mock_instance(:id => 1, :state => 'started')
      stopped = mock_instance(:id => 2, :state => 'stopped')
      @cloud.stub(:instances).and_return([started, stopped])
      running = @base.running_instances
      running.size.should == 1
      running.first[:id].should == started.id
    end

    it "should return a hash containing :id" do
      instance = mock_instance(:id => 1, :state => 'started')
      @cloud.stub(:instances).and_return([instance])
      @base.running_instances.first[:id].should_not be_nil
    end
  end

  describe "managed_instances" do
    before(:each) do
      Instance.stub!(:find_by_cloud_id).and_return(nil)
    end

    it "should be a subset of running instances" do
      @base.should_receive(:running_instances).and_return([])
      @base.managed_instances
    end

    it "should only return instances in our database" do
      cloud_instances = [{:id => "123"}, {:id => "234"}]
      @base.stub!(:running_instances).and_return(cloud_instances)
      instance = Factory.build(:instance)
      Instance.should_receive(:find_by_cloud_id).with("123").and_return(instance)
      @base.managed_instances.size.should == 1
    end
  end

  it "should have no runaway instances" do
    @base.runaway_instances.should be_empty
  end
end
