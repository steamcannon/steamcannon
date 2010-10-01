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
    @valid_attributes = {
      :name => "value for name",
      :platform_version_id => 1,
      :user => mock_model(User)
    }
  end

  it { should have_many :instance_services }
  
  it "should create a new instance given valid attributes" do
    Environment.create!(@valid_attributes)
  end

  it "should have a name attribute" do
    Environment.new.should respond_to(:name)
  end

  it "should belong to a platform version" do
    Environment.new.should respond_to(:platform_version)
  end

  it "should belong to a platform" do
    platform = Platform.new
    version = PlatformVersion.new(:platform => platform)
    environment = Environment.new(:platform_version => version)
    environment.platform.should eql(platform)
  end

  it "should have many images" do
    environment = Environment.new
    environment.images << Image.new
    environment.images << Image.new
    environment.images.size.should be(2)
  end

  it "should have many instances" do
    Environment.new.should respond_to(:instances)
  end

  it "should belong to a user" do
    Environment.new.should respond_to(:user)
  end

  it "should not be able to mass-assign user_id attribute" do
    environment = Environment.new(:user_id => 1)
    environment.user_id.should be_nil
  end

  describe "start" do
    it "should be starting" do
      environment = Environment.new(@valid_attributes)
      environment.start!
      environment.should be_starting
    end

    it "should start environment images" do
      environment_image = EnvironmentImage.new(:num_instances => 1)
      environment = Environment.new(@valid_attributes)
      environment.environment_images << environment_image
      environment_image.should_receive(:start!)
      environment.start!
    end
  end

  describe "run" do
    before(:each) do
      @environment = Environment.new(@valid_attributes)
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
      @environment.should_receive(:instance_services).and_return([instance_service])
      @environment.stub!(:running_all_instances?).and_return(true)
      @environment.run!
    end
  end

  describe "stop" do
    before(:each) do
      @environment = Factory(:environment)
      @environment.current_state = 'running'
      @environment.stub!(:service).and_return(Factory.build(:service))
    end

    it "should be stopping" do
      @environment.stop!
      @environment.should be_stopping
    end

    it "should undeploy all deployments" do
      @deployment = mock(:deployment)
      @environment.stub_chain(:deployments, :deployed).and_return([@deployment])
      @deployment.should_receive(:undeploy!)
      @environment.stop!
    end

    it "should stop all instances" do
      instance = Instance.new
      @environment.stub_chain(:instances, :active).and_return([instance])
      instance.should_receive(:stop!)
      @environment.stop!
    end
  end

  describe "stopped" do
    before(:each) do
      @environment = Environment.new(@valid_attributes)
      @environment.current_state = 'stopping'
    end

    it "should be default for new environments" do
      Environment.new(@valid_attributes).should be_stopped
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


end
