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

describe Environment do
  before(:each) do
    @environment = Factory(:environment)
  end

  it { should have_many :instance_services }
  it { should have_many :storage_volumes }
  it { should have_many :images }
  it { should have_many :instances }
  
  it { should belong_to :user }
  it { should belong_to :platform_version }
  it { should belong_to :cloud_profile }

  it_should_have_events
  
  it "should have a name attribute" do
    @environment.should respond_to(:name)
  end

  it "should have a cloud attribute" do 
    @environment.should respond_to(:cloud)
  end

  it "should delegate to the cloud_profile's cloud for the cloud attribute" do
    cloud = mock(:cloud)
    @environment.cloud_profile.should_receive(:cloud).and_return(cloud)
    @environment.cloud
  end

  it "should have a region attribute" do
    @environment.should respond_to(:region)
  end

  it "should delegate to the cloud_profile's cloud for the region attribute" do
    cloud = mock(:cloud)
    @environment.cloud_profile.stub!(:cloud).and_return(cloud)
    cloud.should_receive(:region)
    @environment.region
  end

  it "should belong to a platform" do
    platform = Platform.new
    version = PlatformVersion.new(:platform => platform)
    environment = Environment.new(:platform_version => version)
    environment.platform.should eql(platform)
  end

  it "should not be able to mass-assign user_id attribute" do
    environment = Environment.new(:user_id => 1)
    environment.user_id.should be_nil
  end

  describe "start_instance" do

    before(:each) do
      @image = Image.new
      @image.stub!(:friendly_id).and_return('image-id')
      @environment_images = [EnvironmentImage.new(:image=>@image)]
      @environment = Factory(:environment, :current_state => 'running', :environment_images=>@environment_images)
    end

    it "should return false if the environment is not running" do
      @environment.current_state = 'stopped'
      @environment.start_instance('image-id').should be_false
    end

    it "should return false if the Image can't be found" do
      @environment.start_instance('foobar').should be_false
    end

    it "should ensure that the EnvironmentImage#can_start_more? instances" do
      @environment_images.first.should_receive(:can_start_more?)
      @environment.start_instance('image-id')
    end

    it "should start another instance if the EnvironmentImage#can_start_more? instances" do
      @environment_images.first.stub!(:can_start_more?).and_return(true)
      @environment_images.first.should_receive(:start_another!)
      @environment.start_instance('image-id')
    end

  end

  describe "start" do
    before(:each) do
      @environment = Factory(:environment)
    end
    it "should be starting" do
      @environment.start!
      @environment.should be_starting
    end

    context "with an environment image" do
      before(:each) do
        @environment_image = Factory(:environment_image, :environment => @environment, :num_instances => 1)
        @environment_image.stub!(:start!)
        @environment.stub!(:environment_images).and_return([@environment_image])
      end

      it "should start environment images" do
        @environment_image.should_receive(:start!)
        @environment.start!
      end

      it "should destroy old instances" do
        instance = mock_model(Instance)
        instance.should_receive(:destroy)
        @environment.should_receive(:instances).and_return([instance])
        @environment.start!
      end

    end
  end

  describe "run" do
    before(:each) do
      @environment.current_state = 'starting'
    end

    it "should be running if running_all_instances" do
      @environment.stub!(:running_all_instances?).and_return(true)
      @environment.run!
      @environment.should be_running
    end

    it "should be starting if not running_all_instances" do
      @environment.stub!(:running_all_instances?).and_return(false)
      @environment.run!

      @environment.should be_starting
    end

    it "should be running_all_instances if all instances are running" do
      instance = Instance.new(:current_state => 'running')
      @environment.instances << instance
      @environment.save!
      @environment.should be_running_all_instances
    end

    it "should not be running_all_instances if all instances are not running" do
      instance = Instance.new(:current_state => 'pending')
      @environment.instances << instance
      @environment.save!
      @environment.should_not be_running_all_instances
    end

    it "should move all instance_services to configuring" do
      instance_service = mock(InstanceService)
      instance_service.should_receive(:configure!)
      @environment.stub_chain(:instance_services, :pending).and_return([instance_service])
      @environment.stub!(:running_all_instances?).and_return(true)
      @environment.run!
    end
  end

  describe "stop" do
    before(:each) do
      @environment = Factory(:environment)
      @environment.current_state = 'running'
      @environment.stub!(:service).and_return(Factory.build(:service))
      @environment.stub!(:stopped_all_instances?).and_return(false)
    end

    it "should be stopping if there are active instances" do
      @environment.should_receive(:stopped_all_instances?).and_return(false)
      @environment.stop!
      @environment.should be_stopping
    end

    it "should be stopped if there are no active instances" do
      @environment.should_receive(:stopped_all_instances?).and_return(true)
      @environment.stop!
      @environment.should be_stopped
    end

    it "should undeploy all deployments" do
      @deployment = mock(:deployment)
      @environment.stub_chain(:deployments, :deployed).and_return([@deployment])
      @deployment.should_receive(:undeploy!)
      @environment.stop!
    end

    
    it "should stop all instances" do
      instance = Instance.new
      @environment.stub_chain(:instances, :not_stopped, :not_stopping).and_return([instance])
      instance.should_receive(:stop!)
      @environment.stop!
    end

    context 'with storage_volumes' do 
      before(:each) do
        @storage_volume = mock(StorageVolume, :detach! => nil)
        @environment.stub!(:storage_volumes).and_return([@storage_volume])
      end
      
      it "should detach the storage_volumes" do
        @storage_volume.should_receive(:detach!)
        @environment.stop!
      end

      it "should destroy the storage volumes if environment is not marked to preserve" do
        @environment.should_receive(:preserve_storage_volumes?).and_return(false)
        @storage_volume.should_receive(:destroy)
        @environment.stop!
      end
      
      it "should not destroy the storage volumes if environment is marked to preserve" do
        @environment.should_receive(:preserve_storage_volumes?).and_return(true)
        @storage_volume.should_not_receive(:destroy)
        @environment.stop!
      end
    end
  end

  describe "stopped" do
    before(:each) do
      @environment.current_state = 'stopping'
    end

    it "should be default for new environments" do
      Factory.build(:environment).should be_stopped
    end

    it "should be stopped if stopped_all_instances" do
      @environment.stub!(:stopped_all_instances?).and_return(true)
      @environment.stopped!
      @environment.should be_stopped
    end

    it "should be stopping if not stopped_all_instances" do
      @environment.stub!(:stopped_all_instances?).and_return(false)
      @environment.stopped!
      @environment.should be_stopping
    end

    it "should have stopped_all_instances if all instances are stopped" do
      instance = Instance.new(:current_state => 'stopped')
      @environment.instances << instance
      @environment.save!
      @environment.should be_stopped_all_instances
    end

    it "should not have stopped_all_instances if all instances are not stopped" do
      instance = Instance.new(:current_state => 'stopping')
      @environment.instances << instance
      @environment.save!
      @environment.should_not be_stopped_all_instances
    end
  end

  context "before_update" do
    context "destroying old environment images" do
      # these tests are ugly ugly
      before(:each) do
        # now this is some setup!
        @environment = Factory(:environment)
        @platform_version = @environment.platform_version
        @image = Factory(:image)
        @platform_version.images << @image
        @platform_version.save
        @environment.images << @image
        @environment.save

        @other_platform_version = Factory(:platform_version)
        @other_image = Factory(:image)
        @other_platform_version.images << @other_image
        @other_platform_version.save
      end

      context "when the platform_version changes" do
        it "should remove environment_images from the old platform_version" do
          @environment.platform_version = @other_platform_version
          @environment.images << @other_image
          @environment.save
          @environment.images.should_not include(@image)
        end

        it "should not remove images that are exclusive to the new platform version" do
          @environment.platform_version = @other_platform_version
          @environment.images << @other_image
          @environment.save
          @environment.images.should include(@other_image)
        end

        it "should not remove images that are in the new platform version as well" do
          @other_platform_version.images << @image
          @other_platform_version.save
          @environment.platform_version = @other_platform_version
          @environment.images << @other_image
          @environment.save
          @environment.images.should =~ [@image, @other_image]
        end
      end
    end
  end

  context "deployment_base_url" do
    before(:each) do
      @environment = Factory(:environment)
    end

    it "should try mod_cluster first" do
      @environment.should_receive(:first_service_base_url).with('mod_cluster').and_return('mod_cluster')
      @environment.deployment_base_url.should == 'mod_cluster'
    end

    it "should try jboss_as second" do
      @environment.should_receive(:first_service_base_url).with('mod_cluster').and_return(nil)
      @environment.should_receive(:first_service_base_url).with('jboss_as').and_return('jboss_as')
      @environment.deployment_base_url.should == 'jboss_as'
    end

    it "should return nil if no mod_cluster or jboss_as" do
      @environment.should_receive(:first_service_base_url).with('mod_cluster').and_return(nil)
      @environment.should_receive(:first_service_base_url).with('jboss_as').and_return(nil)
      @environment.deployment_base_url.should be_nil
    end
  end

  context "first_service_base_url" do
    before(:each) do
      @environment = Factory(:environment)
      @environment.stub!(:instance_services).and_return(InstanceService)
      InstanceService.stub!(:for_service).and_return([])
      @service = Factory(:service)
      Service.stub!(:find_by_name).and_return(@service)
    end

    it "should lookup the service by name" do
      Service.should_receive(:find_by_name).with('service_name').and_return(@service)
      @environment.send(:first_service_base_url, 'service_name')
    end

    it "should lookup instance services for service" do
      @environment.should_receive(:instance_services).and_return(InstanceService)
      InstanceService.should_receive(:for_service)
      @environment.send(:first_service_base_url, 'service_name')
    end

    it "should return nil if no instance services" do
      InstanceService.should_receive(:for_service).and_return([])
      @environment.send(:first_service_base_url, 'service_name').should be_nil
    end

    it "should return agent service's url_for_instance if instance_service found" do
      instance_service = Factory(:instance_service)
      InstanceService.should_receive(:for_service).and_return([instance_service])
      agent_service = mock('agent_service')
      instance_service.should_receive(:agent_service).and_return(agent_service)
      agent_service.should_receive(:url_for_instance).and_return('url_for_instance')
      @environment.send(:first_service_base_url, 'service_name').should == 'url_for_instance'
    end
  end
  
  describe 'instance_state_change' do
    
    it "should respond to instance_state_change" do
      @environment.should respond_to( :instance_state_change )
    end
    
    context "when instance is 'stopped'" do
      before(:each) do
        @instance = Instance.new(:current_state => 'stopped')
        @environment.instances = [@instance]
        @environment.current_state = 'running'
      end
      
      it "should stop the environment when no other instances are running" do
        @environment.instance_state_change(@instance)
        @environment.should be_stopped
      end

      it "should not stop the environment when other instances are running" do
        @environment.instances << Instance.new(:current_state => 'running')
        @environment.instance_state_change(@instance)
        @environment.should_not be_stopped
      end
    end
  end
  
  describe 'instance_states' do
    it "should return a hash of instance states keyed to the intances" do
      running = Instance.new(:current_state => 'running')
      stopped = Instance.new(:current_state => 'stopped')
      @environment.instances << running
      @environment.instances << stopped
      @environment.instance_states.keys.size.should == 2
      @environment.instance_states['running'].size.should == 1
      @environment.instance_states['running'].first.should == running
      @environment.instance_states['stopped'].size.should == 1
      @environment.instance_states['stopped'].first.should == stopped
    end
  end
  
  describe 'clone!' do
    it "should update the name" do
      @environment.clone!.name.should == "#{@environment.name} (copy)"
    end

    it "should set the state to stopped" do
      @environment.clone!.should be_stopped
    end
    
    it "should clone! the environment images" do
      environment_image = mock(EnvironmentImage)
      environment_image.should_receive(:clone!)
      @environment.should_receive(:environment_images).and_return([environment_image])
      @environment.clone!
    end
    
  end

  context "validate_ssh_key_name" do
    before(:each) do
      @environment = Factory(:environment)
      @cloud = mock('cloud')
      @environment.stub!(:cloud).and_return(@cloud)
    end

    it "should validate if ssh_key_name has changed" do
      @environment.ssh_key_name = 'key_name'
      @cloud.should_receive(:valid_key_name?)
      @environment.validate_ssh_key_name
    end

    it "shouldn't validate if ssh_key_name hasn't changed" do
      @cloud.should_not_receive(:valid_key_name?)
      @environment.validate_ssh_key_name
    end

    it "shouldn't validate if ssh_key_name is blank" do
      @environment.ssh_key_name = ''
      @cloud.should_not_receive(:valid_key_name?)
      @environment.validate_ssh_key_name
    end

    it "should add an error if invalid" do
      @environment.ssh_key_name = 'key_name'
      @cloud.should_receive(:valid_key_name?).and_return(false)
      @environment.validate_ssh_key_name
      @environment.errors.size.should be(1)
    end

    it "should not add an error if valid" do
      @environment.ssh_key_name = 'key_name'
      @cloud.should_receive(:valid_key_name?).and_return(true)
      @environment.validate_ssh_key_name
      @environment.errors.size.should be(0)
    end
  end
end
