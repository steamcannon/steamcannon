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
      :number => 2,
      :cloud_id => "value for cloud_id",
      :hardware_profile => "value for hardware_profile",
      :public_address => "value for public_address"
    }

  end

  it { should have_one :server_certificate }
  it { should have_many :instance_services }
  it { should have_many :services }
  it { should have_one :storage_volume }

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


  it "should find the user's cloud" do
    cloud = Object.new
    instance = Instance.new
    instance.stub_chain(:user, :cloud).and_return(cloud)
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

  it "should delegate to user for cloud specific hacks" do
    instance = Factory.build(:instance)
    user = Factory.build(:user)
    instance.should_receive(:user).and_return(user)
    user.should_receive(:cloud_specific_hacks).and_return('hacks')
    instance.cloud_specific_hacks.should == 'hacks'
  end

  it "should delegate to environment for user" do
    instance = Factory.build(:instance)
    user = Factory.build(:user)
    instance.should_receive(:user).and_return(user)
    instance.user.should == user
  end


  describe "instance_launch_options" do
    before(:each) do
      cloud_specific_hacks = mock(Object)
      cloud_specific_hacks.stub!(:launch_options).and_return({})
      @instance = Instance.new
      @instance.stub!(:cloud_specific_hacks).and_return(cloud_specific_hacks)
      @instance.stub_chain(:environment, :user, :ssh_key_name).and_return('something_not_default')
      @instance.stub_chain(:environment, :default_realm).and_return('a_realm_id')
    end

    it "should include the instance user data" do
      @instance.should_receive(:instance_user_data).and_return('ud')
      @instance.send(:instance_launch_options)[:user_data].should == 'ud'
    end

    it "should include the instance hardware profile" do
      @instance.should_receive(:hardware_profile).and_return('m1.small')
      @instance.send(:instance_launch_options)[:hardware_profile].should == 'm1.small'
    end

    it "should include the instance user key_name" do
      @instance.send(:instance_launch_options)[:key_name].should == 'something_not_default'
    end

    it "should include the instance user default_realm as the realm" do
      @instance.send(:instance_launch_options)[:realm].should == 'a_realm_id'
    end
  end

  describe "instance_user_data" do
    before(:each) do
      @instance = Instance.new
      Certificate.stub_chain(:ca_certificate, :certificate).and_return('cert pem')
    end

    it "should include the client cert" do
      Base64.decode64(@instance.send(:instance_user_data)).should == '{"steamcannon_ca_cert":"cert pem"}'
    end

  end

  context "state transitions" do
    before(:each) do
      @instance = Factory.build(:instance)
    end

    describe "setting state_change_timestamp" do
      before(:each) do
        @now = Time.now
        Time.stub!(:now).and_return(@now)
      end

      it "should be set if current_state changes on save" do
        @instance.should_receive(:state_change_timestamp=).with(@now)
        @instance.current_state = 'running'
        @instance.save
      end

      it "should get set on initial save to handle the default state" do
        @instance.should_receive(:state_change_timestamp=).with(@now)
        @instance.save
      end

      it "should not get set if the state does not change" do
        @instance.save
        @instance.should_not_receive(:state_change_timestamp=)
        @instance.public_address = 'something to trigger save'
        @instance.save
      end
    end

    describe "start" do
      before(:each) do
        @cloud_instance = mock(Object, :id => 'i-123',
                               :public_addresses => ['host'],
                               :private_addresses => ['internal_host'])
        @cloud = mock(Object)
        @cloud.stub!(:launch).and_return(@cloud_instance)
        @instance.stub_chain(:image, :cloud_id).and_return('ami-123')
        @instance.stub!(:update_attributes)
        @instance.stub!(:cloud).and_return(@cloud)
        @instance.stub!(:instance_launch_options).and_return({})
      end

      it "should launch instance in cloud" do
        @instance.stub!(:hardware_profile).and_return('small')
        @cloud.should_receive(:launch).with('ami-123', {})
        @instance.start!
      end

      it "should update cloud_id and addresses from cloud" do
        @instance.should_receive(:update_addresses).
          with(@cloud_instance, :cloud_id => 'i-123')
        @instance.start!
      end

      it "should call start_failed! event if error" do
        @cloud.stub!(:launch).and_raise("error")
        @instance.should_receive(:start_failed!)
        @instance.start!
      end
    end

    describe 'attach_volume' do
      before(:each) do
        @instance.current_state = 'starting'
      end

      it "should transition if there is a storage_volume and it is running in the cloud" do
        @instance.should_receive(:has_storage_volume_and_is_running_in_cloud?).and_return(true)
        @instance.attach_volume!
        @instance.should be_attaching_volume
      end
    end

    describe "configure" do
      before(:each) do
        @cloud_instance = mock(Object,
                               :public_addresses => ['host'],
                               :private_addresses => ['private_host'])
        @instance.stub!(:cloud_instance).and_return(@cloud_instance)
        @environment = mock_model(Environment)
        @instance.stub!(:environment).and_return(@environment)
        @instance.current_state = 'starting'
        @instance.stub!(:running_in_cloud?).and_return(true)
        @environment.stub!(:run!)
      end

      it "should be running_in_cloud if running in cloud" do
        @cloud_instance.stub!(:state).and_return('running')
        @instance.should be_running_in_cloud
      end

      it "should be configuring if running_in_cloud" do
        @instance.configure!
        @instance.should be_configuring
      end

      it "should be starting if not running_in_cloud" do
        @instance.stub!(:running_in_cloud?).and_return(false)
        @instance.configure!
        @instance.should be_starting
      end

      it "should update public_address from cloud" do
        @instance.should_receive(:public_address=).with('host')
        @instance.configure!
      end

      it "should also be able to transition from :attaching_volume" do
        @instance.current_state = 'attaching_volume'
        @instance.configure!
        @instance.should be_configuring
      end

    end


    describe "verify" do
      before(:each) do
        @instance.current_state = 'configuring'
      end

      it "should be verifying from configuring" do
        @instance.verify!
        @instance.should be_verifying
      end

    end

    describe "configure_failed" do
      before(:each) do
        @environment = mock_model(Environment)
        @environment.stub!(:failed!)
        @instance.current_state = 'verifying'
        @instance.stub!(:environment).and_return(@environment)
      end

      it "should call failed! event on environment" do
        @environment.should_receive(:failed!)
        @instance.configure_failed!
      end

      %w{ verifying configuring }.each do |from_state|
        it "should be able to transition to configure_failed from #{from_state}" do
          @instance.current_state = from_state
          @instance.configure_failed!
          @instance.should be_configure_failed
        end
      end
    end

    describe "run" do
      before(:each) do
        @cloud_instance = mock(Object, :public_addresses => ['host'])
        @instance.stub!(:cloud_instance).and_return(@cloud_instance)
        @environment = mock_model(Environment)
        @instance.stub!(:environment).and_return(@environment)
        @instance.stub!(:update_cluster_member_addresses)
        @instance.current_state = 'verifying'
        @environment.stub!(:run!)
      end

      %w{ verifying configuring }.each do |from_state|
        it "should be able to transition to running from #{from_state}" do
          @instance.current_state = from_state
          @instance.run!
          @instance.should be_running
        end
      end

      it "should call run! event on environment" do
        @environment.should_receive(:run!)
        @instance.run!
      end

      it "should call update_cluster_member_addresses" do
        @instance.should_receive(:update_cluster_member_addresses)
        @instance.run!
      end

    end

    describe "stop" do
      %w{ pending starting configuring verifying running start_failed unreachable }.each do |from_state|
        it "should be able to transition to stopping from #{from_state}" do
          @instance.current_state = from_state
          @instance.stop!
          @instance.should be_stopping
        end
      end

      it "should be stopping" do
        @instance.stop!
        @instance.should be_stopping
      end

      it "should populate stopped_at" do
        @instance.stop!
        @instance.stopped_at.should_not be_nil
      end

      it "should populate stopped_by" do
        login
        @instance.stop!
        @instance.stopped_by.should be(@current_user.id)
      end

    end

    describe "terminate" do
      it "should terminate instance in cloud" do
        cloud = mock(Object)
        cloud.stub!(:instance_available?).and_return(true)
        cloud.should_receive(:terminate).with('i-123')
        @instance.cloud_id = 'i-123'
        @instance.stub!(:cloud).and_return(cloud)
        @instance.current_state = 'stopping'
        @instance.terminate!
      end

      it "should ensure the instance is available in the cloud before attempting to terminate it" do
        cloud = mock(Object)
        cloud.stub!(:instance_available?).and_return(false)
        cloud.should_not_receive(:terminate)
        @instance.cloud_id = 'i-123'
        @instance.stub!(:cloud).and_return(cloud)
        @instance.current_state = 'stopping'
        @instance.terminate!
      end
    end

    describe "stopped" do
      before(:each) do
        @cloud_instance = mock(Object)
        @instance.stub!(:cloud_instance).and_return(@cloud_instance)
        @environment = mock_model(Environment)
        @instance.stub!(:environment).and_return(@environment)
        @environment.stub!(:stopped!)
        @environment.stub!(:stopping?).and_return(true)
        @environment.stub!(:preserve_storage_volumes?).and_return(true)
        @instance.current_state = 'terminating'
        @instance.stub!(:stopped_in_cloud?).and_return(true)
      end

      it "should be inactive" do
        @instance.stopped!
        Instance.inactive.first.should eql(@instance)
        Instance.active.count.should be(0)
      end

      it "should call stopped! event on environment" do
        @environment.should_receive(:stopped!)
        @instance.stopped!
      end

      it "should be stopped_in_cloud if terminated in cloud" do
        @instance.unstub(:stopped_in_cloud?)
        @cloud_instance.stub!(:state).and_return('terminated')
        @instance.should be_stopped_in_cloud
      end

      it "should be stopped if stopped_in_cloud" do
        @instance.stopped!
        @instance.should be_stopped
      end

      it "should be terminating if not stopped_in_cloud" do
        @instance.stub!(:stopped_in_cloud?).and_return(false)
        @instance.stopped!
        @instance.should be_terminating
      end

      it "should destroy all instance services" do
        instance_service = mock(InstanceService)
        instance_service.should_receive(:destroy)
        @instance.should_receive(:instance_services).and_return([instance_service])
        @instance.stopped!
      end
    end

    describe "start_failed" do
      it "should call failed! event on environment" do
        environment = mock_model(Environment)
        environment.should_receive(:failed!)
        @instance.current_state = 'pending'
        @instance.stub!(:environment).and_return(environment)
        @instance.start_failed!
      end
    end

    describe "to unreachable" do
    %w{ running pending starting configuring verifying configure_failed stopping terminating start_failed }.each do |from_state|
       it "should be able to transition to unreachable from #{from_state}" do
         @instance.current_state = from_state
         @instance.unreachable!
         @instance.should be_unreachable
       end
     end
      it "should call something on the environment to indicate that the environment is possibly in an inconsistent state"
      it "should have a way to recover from a node marked as unreachable that is suddenly available again"
    end
  end

  describe "agent_client" do
    before(:all) do
      @instance = Instance.new
    end

    it "should return an agent client" do
      @instance.agent_client.class.should == AgentClient
    end

    it "should set the service in the agent" do
      @instance.agent_client(:blah).service_name.should == :blah
    end

    it "should default to the first service for the instance if none provided" do
      service = Factory.build(:service)
      @instance.stub!(:services).and_return([service])
      @instance.agent_client.service_name.should == service.name
    end

    it "should accept a service object in addition to a string/symbol" do
      service = Factory.build(:service)
      @instance.agent_client(service).service_name.should == service.name
    end
  end

  describe "agent_running?" do
    before(:each) do
      @agent = mock(AgentClient)
      @instance = Instance.new
      @instance.stub!(:agent_client).and_return(@agent)
    end

    it "should delegate to agent_client#status" do
      @agent.should_receive(:agent_status).and_return('')
      @instance.agent_running?
    end

    it "should return true if the agent responds to a status call" do
      @agent.stub!(:agent_status).and_return('')
      @instance.agent_running?.should be_true
    end

    it "should return false if status raises an AgentClient::RequestFailedError" do
      @agent.stub!(:agent_status).and_raise(AgentClient::RequestFailedError.new(nil))
      @instance.agent_running?.should_not be_true
    end

    it "should not swallow any other exceptions" do
      @agent.stub!(:agent_status).and_raise(StandardError.new)
      lambda do
        @instance.agent_running?
      end.should raise_error
    end

  end

  describe "configure_agent" do
    before(:each) do
      @instance = Factory(:instance, :current_state => 'configuring', :public_address => 'hostname')
    end

    it "should move to verifying state if agent is running" do
      @instance.stub!(:agent_running?).and_return(true)
      @instance.should_receive(:verify!)
      @instance.configure_agent
    end

    it "should not move to verifying state if agent is not running" do
      @instance.stub!(:agent_running?).and_return(false)
      @instance.should_not_receive(:verify!)
      @instance.configure_agent
    end

    it "should move to configure_failed state if moved to :configuring two or more minutes ago" do
      @instance.state_change_timestamp = Time.now - 120.seconds
      @instance.stub!(:agent_running?).and_return(false)
      @instance.should_receive(:configure_failed!)
      @instance.configure_agent
    end

    it "should try to generate the server cert" do
      @instance.should_receive(:generate_server_cert)
      @instance.configure_agent
    end
  end

  describe "generate_server_cert" do
    before(:each) do
      @instance = Factory(:instance, :current_state => 'configuring', :public_address => 'hostname')
    end

    it "should generate a cert" do
      Certificate.should_receive(:generate_server_certificate).with(@instance)
      @instance.send(:generate_server_cert)
    end

    it "should not generate a cert if the public_address is not set on the instance" do
      @instance.public_address = nil
      Certificate.should_not_receive(:generate_server_certificate)
      @instance.send(:generate_server_cert)
    end

    it "should not generate a cert if one already exists" do
      @instance.send(:generate_server_cert)
      @instance.reload
      Certificate.should_not_receive(:generate_server_certificate)
      @instance.send(:generate_server_cert)
    end

    it "should populate server_certificate attribute" do
      cert = Factory(:server_certificate)
      Certificate.stub!(:generate_server_certificate).and_return(cert)
      @instance.send(:generate_server_cert)
      @instance.server_certificate.should == cert
    end
  end

  describe "verify_agent" do
    before(:each) do
      @instance = Factory(:instance)
      @instance.stub!(:run!)
      @instance.stub!(:discover_services)
      @instance.current_state = 'verifying'
    end

    it "should move to :running state if agent is running" do
      @instance.stub!(:agent_running?).and_return(true)
      @instance.should_receive(:run!)
      @instance.verify_agent
    end

    it "should not move to :running state if agent is not running" do
      @instance.stub!(:agent_running?).and_return(false)
      @instance.should_not_receive(:run!)
      @instance.verify_agent
    end

    it "should move to configure_failed state if moved to :verifying two or more minutes ago" do
      @instance.state_change_timestamp = Time.now - 120.seconds
      @instance.stub!(:agent_running?).and_return(false)
      @instance.should_receive(:configure_failed!)
      @instance.verify_agent
    end

    it "should discover agent services" do
      @instance.stub!(:agent_running?).and_return(true)
      @instance.should_receive(:discover_services)
      @instance.verify_agent
    end
  end


  describe "discover_services" do
    before(:each) do
      @instance = Factory(:instance)
      @client = @instance.agent_client
      @instance.stub!(:agent_client).and_return(@client)
      @service = Factory(:service)
    end

    it "should pull the services from the agent" do
      @client.should_receive(:agent_services).and_return([])
      @instance.discover_services
    end

    it "should find_or_create for the service" do
      @client.stub!(:agent_services).and_return([{ 'name' => 'a name', 'full_name' => 'full name'}])
      Service.should_receive(:find_or_create_by_name).with({ 'name' => 'a name', 'full_name' => 'full name' }).and_return(@service)
      @instance.discover_services
    end

    it "should add the service to the instance services relationship" do
      @client.stub!(:agent_services).and_return([{ 'name' => 'a name', 'full_name' => 'full name'}])
      @instance.discover_services
      service = @instance.reload.services.first
      service.should_not be_nil
      service.name.should == 'a name'
    end

  end

  describe "reachable?" do

    before(:each) do
      @instance       = Factory(:instance)
      @cloud          = mock(Object)
      @logger         = mock(Object)

      @instance.stub!(:cloud).and_return(@cloud)
      @instance.stub!(:logger).and_return(@logger)
    end

    it "should return true when the instance is available" do
      @cloud.should_receive(:instance_available?).and_return true
      @instance.reachable?.should be_true
    end

    it "should return false when the instance is unreachable" do
      @cloud.should_receive(:instance_available?).and_return false
      @instance.reachable?.should be_false
    end

  end

  describe 'has_storage_volume_and_is_running_in_cloud?' do
    before(:each) do
      @instance = Instance.new
    end

    it "should be true if there is a storage volume and running_in_cloud? is true" do
      @instance.should_receive(:storage_volume).and_return(mock(StorageVolume))
      @instance.should_receive(:running_in_cloud?).and_return(true)
      @instance.send(:has_storage_volume_and_is_running_in_cloud?).should be_true
    end

    it "should be false if there is a storage volume and running_in_cloud? is false" do
      @instance.should_receive(:storage_volume).and_return(mock(StorageVolume))
      @instance.should_receive(:running_in_cloud?).and_return(false)
      @instance.send(:has_storage_volume_and_is_running_in_cloud?).should_not be_true
    end

    it "should be false if there is no storage volume" do
      @instance.should_receive(:storage_volume).and_return(nil)
      @instance.should_not_receive(:running_in_cloud?)
      @instance.send(:has_storage_volume_and_is_running_in_cloud?).should_not be_true
    end

  end

  describe 'attach_volume' do
    before(:each) do
      @instance = Instance.new
      @storage_volume = mock(StorageVolume, :attach => false)
      @instance.stub!(:storage_volume).and_return(@storage_volume)
      @instance.stub!(:configure!)
      @instance.stub!(:stuck_in_state_for_too_long?).and_return(false)
    end

    it "should attach the volume" do
      @storage_volume.should_receive(:attach)
      @instance.attach_volume
    end

    it "should move to configuring if the attach succeeds" do
      @storage_volume.should_receive(:attach).and_return(true)
      @instance.should_receive(:configure!)
      @instance.attach_volume
    end

    it "should not move to configuring if the attach fails" do
      @storage_volume.should_receive(:attach).and_return(false)
      @instance.should_not_receive(:configure!)
      @instance.attach_volume
    end

    it "should move to start_failed if it waits too long to attach" do
      @instance.should_receive(:stuck_in_state_for_too_long?).and_return(true)
      @instance.should_receive(:start_failed!)
      @instance.attach_volume
    end
  end

  describe 'name' do
    it "should return the image name along with the number" do
      instance = Instance.new(:number => 77)
      image = mock(Image)
      image.should_receive(:name).and_return("The Image")
      instance.should_receive(:image).and_return(image)
      instance.name.should == "The Image #77"
    end
    
  end

  describe 'update_cluster_member_addresses' do
    it 'should have all running instance_services update their addresses' do
      instance_service = mock(InstanceService)
      instance_service.should_receive(:distribute_cluster_member_address)
      @environment.stub_chain(:instance_services, :running).and_return([instance_service])
      instance = Instance.new
      instance.should_receive(:environment).and_return(@environment)
      instance.send(:update_cluster_member_addresses)
    end
  end
end
