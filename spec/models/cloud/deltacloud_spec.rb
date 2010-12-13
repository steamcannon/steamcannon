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

describe Cloud::Deltacloud do
  before(:each) do
    @deltacloud = Cloud::Deltacloud.new('abc', '123', 'ec2', 'bf-egypt-1')
  end

  describe "launch" do
    before(:each) do
      @client = mock(Object)
      @deltacloud.stub!(:client).and_return(@client)
      @deltacloud.stub!(:user_data).and_return('')
    end

    it "should create instance in the cloud" do
      @client.should_receive(:create_instance).
        with('ami-123',
             :hardware_profile => 'm1.small')
      @deltacloud.launch('ami-123', :hardware_profile => 'm1.small')
    end
  end

  describe "terminate" do
    before(:each) do
      @client = mock(Object)
      @deltacloud.stub!(:client).and_return(@client)
      @deltacloud.stub!(:user_data).and_return('')
    end

    it "should not attempt to terminate an instance that doesn't exist" do
      @client.stub!(:instance).with(1).and_return(nil)
      @deltacloud.terminate(1).should == false
    end
  end

  describe "instance_available?" do
    before(:each) do
      @client = mock(Object)
      @instance = mock(Object)
      @instance.stub!(:state).and_return("RUNNING")
      @deltacloud.stub!(:client).and_return(@client)
      @deltacloud.stub!(:user_data).and_return('')
    end

    it "should return false when an instance is not available" do
      @client.stub!(:instance).with(1).and_return(nil)
      @deltacloud.instance_available?(1).should == false
    end

    it "should return false when an instance is in a STOPPED state" do
      @instance.stub!(:state).and_return("STOPPED")
      @client.stub!(:instance).with(1).and_return(@instance)
      @deltacloud.instance_available?(1).should == false
    end

    it "should return the instance if it is available" do
      @client.stub!(:instance).with(1).and_return(@instance)
      @deltacloud.instance_available?(1).should equal(@instance)
    end
  end

  describe "instance_terminated?" do
    before(:each) do
      @client = mock(Object)
      @instance = mock(Object)
      @instance.stub!(:state).and_return("RUNNING")
      @deltacloud.stub!(:client).and_return(@client)
    end

    it "should not be true when the instance is not available" do
      @client.stub!(:instance).with(1).and_return(nil)
      @deltacloud.instance_terminated?(1).should_not == true
    end

    it "should return true when an instance is in a STOPPED state" do
      @instance.stub!(:state).and_return("STOPPED")
      @client.stub!(:instance).with(1).and_return(@instance)
      @deltacloud.instance_terminated?(1).should == true
    end

    it "should return false when an instance is not in a STOPPED state" do
      @client.stub!(:instance).with(1).and_return(@instance)
      @deltacloud.instance_terminated?(1).should == false
    end
  end

  describe "deltacloud_hardware_profiles" do
    before(:each) do
      @client = mock(Object,
                     :hardware_profiles => [])
      @deltacloud.stub!(:client).and_return(@client)
    end

    it "should fetch from cloud" do
      @client.should_receive(:hardware_profiles)
      @deltacloud.send(:deltacloud_hardware_profiles)
    end

    it "should fetch from cache first" do
      Rails.cache.should_receive(:fetch).and_yield
      @deltacloud.send(:deltacloud_hardware_profiles)
    end
  end

  describe "hardware profiles" do
    it "should only return profile names" do
      profile = mock('hardware_profile',
                     :name => 'small')
      profile.should_receive(:name).and_return('small')
      @deltacloud.should_receive(:deltacloud_hardware_profiles).and_return([profile])
      @deltacloud.hardware_profiles.should eql(['small'])
    end
  end

  describe "architecture" do
    it "should find architecture of hardware profile" do
      profile = mock('hardware_profile',
                     :name => 'small')
      profile.stub_chain(:architecture, :value).and_return('i386')
      @deltacloud.should_receive(:deltacloud_hardware_profiles).and_return([profile])
      @deltacloud.architecture('small').should == 'i386'
    end
  end

  describe "client" do
    before(:each) do
      APP_CONFIG ||= {}
    end

    it "should create with right credentials and url" do
      APP_CONFIG[:deltacloud_url] = 'url'
      DeltaCloud.should_receive(:new).with('abc', '123', 'url', { :driver => 'ec2', :provider => 'bf-egypt-1'})
      @deltacloud.client
    end

    it "should only initialize once" do
      DeltaCloud.should_receive(:new).once.and_return(Object.new)
      @deltacloud.client
      @deltacloud.client
    end
  end

  describe "valid_credentials?" do
    it "should validate with right credentials and url" do
      APP_CONFIG[:deltacloud_url] = 'url'
      DeltaCloud.should_receive(:valid_credentials?).with('abc', '123', 'url', { :driver => 'ec2', :provider => 'bf-egypt-1'})
      @deltacloud.valid_credentials?
    end
  end

  describe "valid_key_name?" do
    before(:each) do
      @client = mock('client')
      @deltacloud.stub!(:client).and_return(@client)
    end

    it "should retrieve all keys from client" do
      @client.should_receive(:keys).and_return([])
      @deltacloud.valid_key_name?('key')
    end

    it "should return true if key ids include key_name" do
      key = mock('key', :id => 'key')
      key2 = mock('key', :id => 'key2')
      @client.stub!(:keys).and_return([key, key2])
      @deltacloud.valid_key_name?('key').should be(true)
    end

    it "should return false if key ids does not include key_name" do
      key = mock('key', :id => 'key')
      key2 = mock('key', :id => 'key2')
      @client.stub!(:keys).and_return([key, key2])
      @deltacloud.valid_key_name?('key3').should be(false)
    end
  end

  describe 'attempt' do
    
    context "on error" do
      before(:each) do
        @error = DeltaCloud::API::BackendError.new
        @deltacloud.should_receive(:some_method).and_raise(@error)
      end
      it "should catch Deltacloud backend error" do
        lambda {
          @deltacloud.attempt(:some_method)
        }.should_not raise_error
      end
      
      it "should store the error in last_error" do
        @deltacloud.attempt(:some_method)
        @deltacloud.last_error.should == @error
      end
      it "should return the default value" do
        @deltacloud.attempt(:some_method, 'blah').should == 'blah'
      end
    end
    
    it "should return the value from the method call" do
      @deltacloud.should_receive(:some_method).and_return('blech')
      @deltacloud.attempt(:some_method, 'blah').should == 'blech'
    end

    it "should pop off the last arg as the default value" do
      @deltacloud.should_receive(:some_method).with(1)
      @deltacloud.attempt(:some_method, 1, 'blah')
    end
    
  end
end
