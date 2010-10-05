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
    @deployment = Factory.build(:deployment, :environment => @environment)
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

      it "should create an deployment_istance_service record" do
        @agent_service.deploy(@instance_service, @deployment)
        @instance_service.deployments.first.should == @deployment
      end
    end

    context "on a failed deploy" do
      before(:each) do
        @agent_client.stub!(:deploy_artifact).and_raise(AgentClient::RequestFailedError.new('msg'))
      end

      it "should not create an deployment_instance_service record" do
        @agent_service.deploy(@instance_service, @deployment)
        @instance_service.deployments.should be_empty
      end

      it "should not raise"  do
        lambda{
          @agent_service.deploy(@instance_service, @deployment)
        }.should_not raise_error(AgentClient::RequestFailedError)
      end

      it "should return !true" do
        @agent_service.deploy(@instance_service, @deployment).should_not == true
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

      it "should delete the deployment_instance_service record" do
        @agent_service.undeploy(@instance_service, @deployment)
        @instance_service.deployments.should be_empty
      end
    end

    context "on a failed undeploy" do
      before(:each) do
        @agent_client.stub!(:undeploy_artifact).and_raise(AgentClient::RequestFailedError.new('msg'))
      end

      it "should not delete the deployment_instance_service record" do
        @agent_service.undeploy(@instance_service, @deployment)
        @instance_service.deployments.first.should == @deployment
      end

      it "should not raise"  do
        lambda{
          @agent_service.undeploy(@instance_service, @deployment)
        }.should_not raise_error(AgentClient::RequestFailedError)
      end

      it "should return !true" do
        @agent_service.undeploy(@instance_service, @deployment).should_not == true
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

  describe 'open_ports' do
    it "should be empty" do
      @agent_service.open_ports.should be_empty
    end
  end

end
