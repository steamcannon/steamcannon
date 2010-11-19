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
    @instance_service = Factory.build(:instance_service)
    @deployment = Factory(:deployment, :environment => @environment)
    @deployment.stub!(:artifact_identifier).and_return('art_id')
    @deployment.stub!(:perform_deploy)
    @deployment.stub!(:mark_as_deployed!)
    @deployment.stub!(:fail!)
    @agent_service.stub!(:instance_services_for_deploy).and_return([@instance_service])
  end

  describe 'instance_for_service' do
    class AgentServices::Dummy < AgentServices::Base
    end

    it 'should look up the service class based on the service name' do
      @service.stub!(:name).and_return('dummy')
      AgentServices::Base.should_receive(:require).with('agent_services/dummy')
      AgentServices::Base.instance_for_service(@service, @environment).is_a?(AgentServices::Dummy).should == true
    end

    it 'should return an instance of the default service if no service can be found' do
      @service.stub!(:name).and_return('blah')
      AgentServices::Base.instance_for_service(@service, @environment).is_a?(AgentServices::Base).should == true

    end
  end

  describe 'deploy' do
    before(:each) do
      @instance_service.save
      @agent_client = mock(AgentClient)
      @instance_service.stub!(:agent_client).and_return(@agent_client)
      @artifact_version = mock(ArtifactVersion)
      @artifact = mock(Artifact)
      @artifact.stub!(:deployment_for_instance_service).and_return(nil)
      @deployment.stub!(:artifact_version).and_return(@artifact_version)
      @deployment.stub!(:artifact).and_return(@artifact)
    end

    it "should set the artifact id on the deployment if given" do
      @agent_client.stub(:deploy_artifact).and_return({ 'artifact_id' => 1234})
      @agent_service.deploy(@instance_service, @deployment)
      @deployment.agent_artifact_identifier.should == 1234
    end

    it "should undeploy if another version of the artifact is already deployed to the instance_service" do
      other_deployment = mock(Deployment)
      @artifact.should_receive(:deployment_for_instance_service).with(@instance_service).and_return(other_deployment)
      other_deployment.should_receive(:undeploy!)
      @agent_client.stub!(:deploy_artifact)
      @agent_service.deploy(@instance_service, @deployment)
    end

    it "should deploy" do
      @agent_client.should_receive(:deploy_artifact).with(@artifact_version)
      @agent_service.deploy(@instance_service, @deployment)
    end

    context "when the deployment has already been deployed to the instance" do
      before(:each) do
        @instance_service.deployments << @deployment
      end

      it "should not deploy again" do
        @agent_client.should_not_receive(:deploy_artifact)
        @agent_service.deploy(@instance_service, @deployment)
      end
    end

    context "on a successful deploy" do
      before(:each) do
        @agent_client.stub!(:deploy_artifact).and_return({ 'artifact_id' => 77 })
      end

      it "should return true" do
        @agent_service.deploy(@instance_service, @deployment).should be_true
      end

      it "should create an deployment_instance_service record" do
        @agent_service.deploy(@instance_service, @deployment)
        @instance_service.deployments.first.should == @deployment
      end


      context "with a returned status" do
        it "should move the deployment_instance_service to deployed if the deploy finished" do
          @agent_client.stub!(:deploy_artifact).and_return({ 'status' => 'deployed' })
          @agent_service.deploy(@instance_service, @deployment)
          @instance_service.deployment_instance_services.first.should be_deployed
        end

        it "should leave the deployment_instance_service in pending if the deploy is still pending" do
          @agent_client.stub!(:deploy_artifact).and_return({ 'status' => 'pending' })
          @agent_service.deploy(@instance_service, @deployment)
          @instance_service.deployment_instance_services.first.should be_pending
        end

      end

      context "with no returned status" do
        it "should move the deployment_instance_service to deployed" do
          @agent_service.deploy(@instance_service, @deployment)
          @instance_service.deployment_instance_services.first.should be_deployed
        end
      end
    end

    context "on a failed deploy" do
      before(:each) do
        @error = AgentClient::RequestFailedError.new('deploy failure')
        @agent_client.stub!(:deploy_artifact).and_raise(@error)
        @deployment_instance_service = DeploymentInstanceService.new
        @instance_service.stub_chain(:deployment_instance_services, :create).and_return(@deployment_instance_service)
      end

      it "should create an deployment_instance_service record with a state of :deploy_failed" do
        @agent_service.deploy(@instance_service, @deployment)
        @deployment_instance_service.should be_deploy_failed
      end

      it "should set the last error on the deployment_instance_service to the exception" do
        @agent_service.deploy(@instance_service, @deployment)
        @deployment_instance_service.last_error.should == @error
      end
      
      it "should not raise"  do
        lambda{
          @agent_service.deploy(@instance_service, @deployment)
        }.should_not raise_error(AgentClient::RequestFailedError)
      end

      it "should return !true" do
        @agent_service.deploy(@instance_service, @deployment).should_not == true
      end
      
      it "should store the exception" do
        @agent_service.deploy(@instance_service, @deployment)
        error = @agent_service.last_error
        error.message.should == 'deploy failure'
      end
    end

  end


  describe 'undeploy' do
    before(:each) do
      @instance_service.save
      @agent_client = mock(AgentClient)
      @instance_service.stub!(:agent_client).and_return(@agent_client)
      @artifact_version = mock(ArtifactVersion)
      @deployment.stub!(:artifact_version).and_return(@artifact_version)
      @instance_service.deployments << @deployment
      @deployment_instance_service = @instance_service.deployment_instance_services.find_by_deployment_id(@deployment.id)
      @instance_service.stub_chain(:deployment_instance_services, :find_by_deployment_id).and_return(@deployment_instance_service)
      @deployment_instance_service.deployed!
    end

    it "should undeploy" do
      @deployment.stub!(:artifact_identifier).and_return('the_id')
      @agent_client.should_receive(:undeploy_artifact).with('the_id')
      @agent_service.undeploy(@instance_service, @deployment)
    end

    context "on a successful undeploy" do
      before(:each) do
        @agent_client.stub!(:undeploy_artifact)
      end

      it "should return true" do
        @agent_service.undeploy(@instance_service, @deployment).should == true
      end

      it "should move the deployment_instance_service to :undeployed" do
        @deployment_instance_service.should_receive(:undeployed!)
        @agent_service.undeploy(@instance_service, @deployment)
      end
      
      it "should delete the deployment_instance_service record" do
        @agent_service.undeploy(@instance_service, @deployment)
        @instance_service.deployments.should be_empty
      end
    end

    context "on a failed undeploy" do
      before(:each) do
        @error = AgentClient::RequestFailedError.new('msg')
        @agent_client.stub!(:undeploy_artifact).and_raise(@error)
      end

      it "should not delete the deployment_instance_service record" do
        @agent_service.undeploy(@instance_service, @deployment)
        @instance_service.deployments.first.should == @deployment
      end

      it "should move the deployment_instance_service to undeploy_failed" do
        @deployment_instance_service.should_receive(:fail!)
        @agent_service.undeploy(@instance_service, @deployment)
      end
      
      it "should set the last error to the exception" do
        @agent_service.undeploy(@instance_service, @deployment)
        @agent_service.last_error.should == @error
      end
      
      it "should set the last error on the deployment_instance_service to the exception" do
        @agent_service.undeploy(@instance_service, @deployment)
        @deployment_instance_service.last_error.should == @error
      end
      
      it "should not raise"  do
        lambda{
          @agent_service.undeploy(@instance_service, @deployment)
        }.should_not raise_error(AgentClient::RequestFailedError)
      end

      it "should return !true" do
        @agent_service.undeploy(@instance_service, @deployment).should_not == true
      end

      it "should store the exception" do
        @agent_service.undeploy(@instance_service, @deployment)
        error = @agent_service.last_error
        error.message.should == 'msg'
      end
    end

  end

  describe 'configure_instance_service' do
    it "should log a debug message" do
      Rails.logger.should_receive(:debug)
      @agent_service.configure_instance_service(@instance_service)
    end

    it "should return true" do
      @agent_service.configure_instance_service(@instance_service).should be_true
    end
  end

  describe "open_ports" do
    it "should be empty" do
      @agent_service.open_ports.should be_empty
    end
  end

  describe "url_for_instance" do
    it "should default to nil" do
      instance = Factory(:instance)
      @agent_service.url_for_instance(instance).should be_nil
    end
  end

  describe "url_for_instance_service" do
    it "should default to nil" do
      instance_service = Factory(:instance_service)
      @agent_service.url_for_instance_service(instance_service).should be_nil
    end
  end

end
