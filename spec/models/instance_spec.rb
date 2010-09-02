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

describe Instance do
  before(:each) do
    @image = mock_model(Image)
    @image.stub!(:cloud_id).and_return("ami-12345")
    @environment = mock_model(Environment)

    @valid_attributes = {
      :environment => @environment,
      :image => @image,
      :name => "value for name",
      :cloud_id => "value for cloud_id",
      :hardware_profile => "value for hardware_profile",
      :public_dns => "value for public_dns"
    }

    InstanceTask.stub(:async)
  end

  it "should create a new instance given valid attributes" do
    Instance.create!(@valid_attributes)
  end

  it "should belong to an environment" do
    Instance.new.should respond_to(:environment)
  end

  it "should belong to an image" do
    Instance.new.should respond_to(:image)
  end

  it "should be active after creation" do
    instance = Instance.create!(@valid_attributes)
    Instance.active.first.should eql(instance)
    Instance.inactive.count.should be(0)
  end

  describe "deploy" do
    it "should populate started_at" do
      instance = Instance.deploy!(@image, @environment, "test", "small")
      instance.started_at.should_not be_nil
    end

    it "should populate started_by" do
      login
      instance = Instance.deploy!(@image, @environment, "test", "small")
      instance.started_by.should be(@current_user.id)
    end

    it "should be pending" do
      instance = Instance.deploy!(@image, @environment, "test", "small")
      instance.should be_pending
    end
  end

  it "should generate certs on creation"
  
  it "should find the user's cloud" do
    cloud = Object.new
    instance = Instance.new
    instance.stub_chain(:environment, :user, :cloud).and_return(cloud)
    instance.cloud.should eql(cloud)
  end

  it "should find cloud instance by cloud_id attribute" do
    cloud_instance = Object.new
    cloud = Object.new
    cloud.should_receive(:instance).with('i-123').and_return(cloud_instance)
    instance = Instance.new(:cloud_id => 'i-123')
    instance.stub!(:cloud).and_return(cloud)
    instance.cloud_instance.should be(cloud_instance)
  end

  
  describe "instance_launch_options" do
    it "should include the instance user data" do
      @instance = Instance.new
      @instance.should_receive(:instance_user_data).and_return('ud')
      @instance.send(:instance_launch_options).should == { :user_data => 'ud'}
    end
  end

  describe "instance_user_data" do
    before(:each) do
      @instance = Instance.new
      Certificate.stub_chain(:client_certificate, :certificate).and_return('cert pem')
    end
    
    it "should include the client cert if using ssl with agents" do
      # ssl usage is the default
      @instance.send(:instance_user_data).should == '{"steamcannon_client_cert":"cert pem"}'
    end

    it "should not include the cert if not using ssl with agents" do
      APP_CONFIG[:use_ssl_with_agents] = false
      @instance.send(:instance_user_data).should == '{}'
    end

  end
  
  describe "start" do
    before(:each) do
      @cloud_instance = mock(Object, :id => 'i-123',
                             :public_addresses => ['host'])
      @cloud = mock(Object)
      @cloud.stub!(:launch).and_return(@cloud_instance)
      @instance = Instance.new
      @instance.stub_chain(:image, :cloud_id).and_return('ami-123')
      @instance.stub!(:update_attributes)
      @instance.stub!(:cloud).and_return(@cloud)
      @instance.stub!(:instance_launch_options).and_return({})
    end

    it "should launch instance in cloud" do
      @instance.stub!(:hardware_profile).and_return('small')
      @cloud.should_receive(:launch).with('ami-123', 'small', {})
      @instance.start!
    end
    
    it "should update cloud_id and public_dns from cloud" do
      @instance.should_receive(:update_attributes).
        with(:cloud_id => 'i-123', :public_dns => 'host')
      @instance.start!
    end

    it "should call failed! event if error" do
      @cloud.stub!(:launch).and_raise("error")
      @instance.should_receive(:failed!)
      @instance.start!
    end
  end

  describe "run" do
    before(:each) do
      @cloud_instance = mock(Object, :public_addresses => ['host'])
      @instance = Instance.new
      @instance.stub!(:cloud_instance).and_return(@cloud_instance)
      @environment = mock_model(Environment)
      @instance.stub!(:environment).and_return(@environment)
      @environment.stub!(:run!)
    end

    it "should be running_in_cloud if running in cloud" do
      @cloud_instance.stub!(:state).and_return('running')
      @instance.should be_running_in_cloud
    end

    it "should be running if running_in_cloud" do
      @instance.stub!(:running_in_cloud?).and_return(true)
      @instance.current_state = 'starting'
      @instance.run!
      @instance.should be_running
    end

    it "should be starting if not running_in_cloud" do
      @instance.stub!(:running_in_cloud?).and_return(false)
      @instance.current_state = 'starting'
      @instance.run!
      @instance.should be_starting
    end

    it "should update public_dns from cloud" do
      @instance.stub!(:running_in_cloud?).and_return(true)
      @instance.current_state = 'starting'
      @instance.should_receive(:public_dns=).with('host')
      @instance.run!
    end

    it "should call run! event on environment" do
      @instance.stub!(:running_in_cloud?).and_return(true)
      @instance.current_state = 'starting'
      @environment.should_receive(:run!)
      @instance.run!
    end
  end

  describe "stop" do
    it "should be stopping" do
      instance = Instance.create!(@valid_attributes)
      instance.stop!
      instance.should be_stopping
    end

    it "should populate stopped_at" do
      instance = Instance.create!(@valid_attributes)
      instance.stop!
      instance.stopped_at.should_not be_nil
    end

    it "should populate stopped_by" do
      login
      instance = Instance.create!(@valid_attributes)
      instance.stop!
      instance.stopped_by.should be(@current_user.id)
    end
  end

  describe "terminate" do
    it "should terminate instance in cloud" do
      cloud = mock(Object)
      cloud.should_receive(:terminate).with('i-123')
      instance = Instance.new(:cloud_id => 'i-123')
      instance.stub!(:cloud).and_return(cloud)
      instance.current_state = 'stopping'
      instance.terminate!
    end
  end

  describe "stopped" do
    before(:each) do
      @cloud_instance = mock(Object)
      @instance = Instance.new
      @instance.stub!(:cloud_instance).and_return(@cloud_instance)
      @environment = mock_model(Environment)
      @instance.stub!(:environment).and_return(@environment)
      @environment.stub!(:stopped!)
    end

    it "should be inactive" do
      @instance.stub!(:stopped_in_cloud?).and_return(true)
      @instance.current_state = 'terminating'
      @instance.stopped!
      Instance.inactive.first.should eql(@instance)
      Instance.active.count.should be(0)
    end

    it "should call stopped! event on environment" do
      @instance.stub!(:stopped_in_cloud?).and_return(true)
      @instance.current_state = 'terminating'
      @environment.should_receive(:stopped!)
      @instance.stopped!
    end

    it "should be stopped_in_cloud if terminated in cloud" do
      @cloud_instance.stub!(:state).and_return('terminated')
      @instance.should be_stopped_in_cloud
    end

    it "should be stopped if stopped_in_cloud" do
      @instance.stub!(:stopped_in_cloud?).and_return(true)
      @instance.current_state = 'terminating'
      @instance.stopped!
      @instance.should be_stopped
    end

    it "should be terminating if not stopped_in_cloud" do
      @instance.stub!(:stopped_in_cloud?).and_return(false)
      @instance.current_state = 'terminating'
      @instance.stopped!
      @instance.should be_terminating
    end
  end

  describe "start_failed" do
    it "should call failed! event on environment" do
      environment = mock_model(Environment)
      environment.should_receive(:failed!)
      instance = Instance.new
      instance.current_state = 'pending'
      instance.stub!(:environment).and_return(environment)
      instance.failed!
    end
  end

end
