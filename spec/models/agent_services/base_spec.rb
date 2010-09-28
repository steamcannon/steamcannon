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


describe AgentServices::Base do
  before(:each) do
    @service = Factory.build(:service)
    @environment = Factory(:environment)
    @environment.stub!(:trigger_deployments)
    @agent_service = AgentServices::Base.new(@service, @environment)
    @instance = Factory.build(:instance)
    @deployment = Factory.build(:deployment, :environment => @environment)
    @deployment.stub!(:mark_as_deployed!)
    @deployment.stub!(:fail!)
    @agent_service.stub!(:instances_for_deploy).and_return([@instance])
  end

  describe 'instance_for_service' do
    class AgentServices::Dummy < AgentServices::Base
    end

    it 'should look up the service class based on the service name' do
      @service.should_receive(:name).twice.and_return('dummy')
      AgentServices::Base.should_receive(:require).with('agent_services/dummy')
      AgentServices::Base.instance_for_service(@service, @environment).is_a?(AgentServices::Dummy).should == true
    end

    it 'should return an instance of the default service if no service can be found' do
      @service.should_receive(:name).and_return('blah')
      AgentServices::Base.instance_for_service(@service, @environment).is_a?(AgentServices::Base).should == true

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
      @instance.save
      @agent_client = mock(AgentClient)
      @instance.stub!(:agent_client).and_return(@agent_client)
      @artifact_version = mock(ArtifactVersion)
      @artifact = mock(Artifact)
      @artifact.stub!(:deployment_for_instance).and_return(nil)
      @deployment.stub!(:artifact_version).and_return(@artifact_version)
      @deployment.stub!(:artifact).and_return(@artifact)
    end

    it "should undeploy if another version of the artifact is already deployed to the instance" do
      other_deployment = mock(Deployment)
      @artifact.should_receive(:deployment_for_instance).with(@instance).and_return(other_deployment)
      @agent_service.should_receive(:undeploy).with(other_deployment)
      @agent_client.stub!(:deploy_artifact)
      @agent_service.deploy_to_instance(@instance, @deployment)
    end

    it "should deploy" do
      @agent_client.should_receive(:deploy_artifact).with(@artifact_version)
      @agent_service.deploy_to_instance(@instance, @deployment)
    end

    context "when the deployment has already been deployed to the instance" do
      before(:each) do
        @instance.deployments << @deployment
      end
      
      it "should not deploy again" do
        @agent_client.should_not_receive(:deploy_artifact)
        @agent_service.deploy_to_instance(@instance, @deployment)
      end
    end
    
    context "on a successful deploy" do
      before(:each) do
        @agent_client.stub!(:deploy_artifact).and_return({ 'artifact_id' => 77 })
      end

      it "should return an artifact_id (HACK until we impl STEAM-85)" do
        @agent_service.deploy_to_instance(@instance, @deployment).should == 77
      end

      it "should create an instance_deployment record" do
        @agent_service.deploy_to_instance(@instance, @deployment)
        @instance.deployments.first.should == @deployment
      end
    end

    context "on a failed deploy" do
      before(:each) do
        @agent_client.stub!(:deploy_artifact).and_raise(AgentClient::RequestFailedError.new('msg'))
      end

      it "should not create an instance_deployment record" do
        @agent_service.deploy_to_instance(@instance, @deployment)
        @instance.deployments.should be_empty
      end

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
    before(:each) do
      @agent_service.stub!(:undeploy_from_instance).and_return(true)
      @deployment.stub!(:instances).and_return([@instance])
    end

    it "should delegate to undeploy_from_instance for each instance" do
      @agent_service.should_receive(:undeploy_from_instance).with(@instance, @deployment)
      @agent_service.undeploy(@deployment)
    end

    context "when undeployment succeeds to all instances" do
      before(:each) do
        @instance_two = Factory.build(:instance)
        @deployment.stub!(:instances).and_return([@instance, @instance_two])
        @agent_service.should_receive(:undeploy_from_instance).twice.and_return(true)
      end

      it "should mark the deployment as undeployed" do
        @deployment.should_receive(:mark_as_undeployed!)
        @agent_service.undeploy(@deployment)
      end
    end
    
    context "when undeployment fails on one instance" do
      before(:each) do
        @instance_two = Factory.build(:instance)
        @deployment.stub!(:instances).and_return([@instance, @instance_two])
        @agent_service.should_receive(:undeploy_from_instance).twice.and_return(true, false)
      end

      it "should not mark the deployment as undeployed" do
        @deployment.should_not_receive(:mark_as_undeployed!)
        @agent_service.undeploy(@deployment)
      end
    end

    context "when there are no instances to undeploy from" do
      before(:each) do
        @deployment.stub!(:instances_for_deploy).and_return([])
      end

      it "should mark the deployment as undeployed" do
        @deployment.should_receive(:mark_as_undeployed!)
        @agent_service.undeploy(@deployment)
      end

    end

  end

  describe 'undeploy_from_instance' do
    before(:each) do
      @instance.save
      @agent_client = mock(AgentClient)
      @instance.stub!(:agent_client).and_return(@agent_client)
      @artifact_version = mock(ArtifactVersion)
      @deployment.stub!(:artifact_version).and_return(@artifact_version)
      @instance.deployments << @deployment
    end

    it "should undeploy" do
      @deployment.stub!(:agent_artifact_identifier).and_return(77)
      @agent_client.should_receive(:undeploy_artifact).with(77)
      @agent_service.undeploy_from_instance(@instance, @deployment)
    end

    context "on a successful undeploy" do
      before(:each) do
        @agent_client.stub!(:undeploy_artifact)
      end

      it "should return true" do
        @agent_service.undeploy_from_instance(@instance, @deployment).should == true
      end

      it "should delete the instance_deployment record" do
        @agent_service.undeploy_from_instance(@instance, @deployment)
        @instance.deployments.should be_empty
      end
    end

    context "on a failed undeploy" do
      before(:each) do
        @agent_client.stub!(:undeploy_artifact).and_raise(AgentClient::RequestFailedError.new('msg'))
      end

      it "should not delete the instance_deployment record" do
        @agent_service.undeploy_from_instance(@instance, @deployment)
        @instance.deployments.first.should == @deployment
      end

      it "should not raise"  do
        lambda{
          @agent_service.undeploy_from_instance(@instance, @deployment)
        }.should_not raise_error(AgentClient::RequestFailedError)
      end

      it "should return !true" do
        @agent_service.undeploy_from_instance(@instance, @deployment).should_not == true
      end
    end

  end

  
end
