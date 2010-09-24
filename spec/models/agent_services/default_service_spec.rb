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


describe AgentServices::DefaultService do
  before(:each) do
    @service = Factory.build(:service)
    @environment = Factory.build(:environment)
    @agent_service = AgentServices::DefaultService.new(@service, @environment)
    @instance = Factory.build(:instance)
    @deployment = Factory.build(:deployment)
    @deployment.stub!(:mark_as_deployed!)
    @deployment.stub!(:fail!)
    @agent_service.stub!(:instances_for_deploy).and_return([@instance])
  end

  describe 'instance_for_service' do
    class AgentServices::DummyService < AgentServices::DefaultService
    end

    it 'should look up the service class based on the service name' do
      @service.should_receive(:name).and_return('dummy')
      AgentServices::DefaultService.instance_for_service(@service, @environment).is_a?(AgentServices::DummyService).should == true
    end

    it 'should return an instance of the default service if no service can be found' do
      @service.should_receive(:name).and_return('blah')
      AgentServices::DefaultService.instance_for_service(@service, @environment).is_a?(AgentServices::DefaultService).should == true

    end
  end
  
  describe 'deploy' do
    before(:each) do
      @agent_service.stub!(:deploy_to_instance).and_return(77)
    end

    it "should delegate to deploy_to_instance for each instance and deployment" do
      @agent_service.should_receive(:deploy_to_instance).with(@instance, @deployment)
      @agent_service.deploy([@deployment])
    end

    it "should set the artifact id on the deployment (HACK until we impl STEAM-85)" do
      @deployment.should_receive(:agent_artifact_identifier=).with(77)
      @agent_service.deploy([@deployment])
    end


    context "when deployment succeeds to all instances" do
      before(:each) do
        @instance_two = Factory.build(:instance)
        @agent_service.stub!(:instances_for_deploy).and_return([@instance, @instance_two])
        @agent_service.should_receive(:deploy_to_instance).twice.and_return(77)
      end

      it "should mark the deployment as deployed" do
        @deployment.should_receive(:mark_as_deployed!)
        @agent_service.deploy([@deployment])
      end

      it "should not mark the deployment as failed " do
        @deployment.should_not_receive(:fail!)
        @agent_service.deploy([@deployment])
      end
    end
    
    context "when deployment fails on one instance" do
      before(:each) do
        @instance_two = Factory.build(:instance)
        @agent_service.stub!(:instances_for_deploy).and_return([@instance, @instance_two])
        @agent_service.should_receive(:deploy_to_instance).twice.and_return(77, false)
      end

      it "should not mark the deployment as deployed" do
        @deployment.should_not_receive(:mark_as_deployed!)
        @agent_service.deploy([@deployment])
      end

      it "should mark the deployment as failed " do
        @deployment.should_receive(:fail!)
        @agent_service.deploy([@deployment])
      end
    end

    context "when there are no instances to deploy to" do
      before(:each) do
        @agent_service.stub!(:instances_for_deploy).and_return([])
      end

      it "should not mark the deployment as deployed" do
        @deployment.should_not_receive(:mark_as_deployed!)
        @agent_service.deploy([@deployment])
      end

      it "should not mark the deployment as failed " do
        @deployment.should_not_receive(:fail!)
        @agent_service.deploy([@deployment])
      end
    end

  end

  describe 'deploy_to_instance' do
    before(:each) do
      @agent_client = mock(AgentClient)
      @instance.stub!(:agent_client).and_return(@agent_client)
      @artifact_version = mock(ArtifactVersion)
      @deployment.stub!(:artifact_version).and_return(@artifact_version)
    end

    it "should undeploy if another version of the artifact is already deployed to the instance"
    it "should skip the deployment if the deployment is already deployed to instance"


    it "should deploy" do
      @agent_client.should_receive(:deploy_artifact).with(@artifact_version)
      @agent_service.deploy_to_instance(@instance, @deployment)
    end

    context "on a successful deploy" do
      before(:each) do
        @agent_client.stub!(:deploy_artifact).and_return({ 'artifact_id' => 77 })
      end

      it "should return an artifact_id (HACK until we impl STEAM-85)" do
        @agent_service.deploy_to_instance(@instance, @deployment).should == 77
      end

      it "should create an instance_deployment record"
    end

    context "on a failed deploy" do
      before(:each) do
        @agent_client.stub!(:deploy_artifact).and_raise(AgentClient::RequestFailedError.new('msg'))
      end

      it "should not create an instance_deployment record"

      it "should not raise"  do
        lambda{
          @agent_service.deploy_to_instance(@instance, @deployment)
        }.should_not raise_error(AgentClient::RequestFailedError)
      end

      it "should return !true" do
        @agent_service.deploy_to_instance(@instance, @deployment).should_not == true
      end
    end

  end
  describe 'undeploy' do
  end
end
