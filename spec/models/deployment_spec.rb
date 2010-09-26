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

describe Deployment do
  it { should have_many :instance_deployments }
  it { should have_many :instances }

  before(:each) do
    @deployment = Factory(:deployment)
    @deployment.current_state = 'deploying'
    @environment = @deployment.environment
    @environment.stub!(:trigger_deployments)
  end

  it "should belong to an artifact" do
    artifact = Artifact.new
    artifact_version = ArtifactVersion.new
    artifact_version.artifact = artifact
    deployment = Deployment.new
    deployment.artifact_version = artifact_version
    deployment.artifact.should equal(artifact)
  end

  it "should tell the environment to trigger deployments after creation" do
    @environment.should_receive(:trigger_deployments).with(@deployment)
    @deployment.send(:notify_environment_of_deploy)
  end

  it "should be active after deploying" do
    @deployment.mark_as_deployed!
    Deployment.active.first.should eql(@deployment)
    Deployment.inactive.count.should be(0)
  end

  it "should populate deployed_at after moving to :deployed" do
    @deployment.deployed_at.should_not be_nil
  end

  it "should populate deployed_by after deploy" do
    login
    @deployment.mark_as_deployed!
    @deployment.deployed_by.should be(@current_user.id)
  end

  it "should be inactive after undeploying" do
    @deployment.current_state = 'deployed'
    @deployment.mark_as_undeployed!
    Deployment.inactive.first.should eql(@deployment)
    Deployment.active.count.should be(0)
  end

  it "should populate undeployed_at after undeploying" do
    @deployment.current_state = 'deployed'
    @deployment.mark_as_undeployed!
    @deployment.undeployed_at.should_not be_nil
  end

  it "should populate undeployed_by after undeploying" do
    login
    @deployment.current_state = 'deployed'
    @deployment.mark_as_undeployed!
    @deployment.undeployed_by.should be(@current_user.id)
  end


=begin
  describe "deploy" do
    before(:each) do
      @service = Factory.build(:service)
      @artifact = Factory.build(:artifact)
      @artifact_version = Factory.build(:artifact_version)
      @instance = Factory.build(:instance)
      @deployment = Factory.build(:deployment)
      @environment = Factory.build(:environment)
      @agent_client = mock(AgentClient)
      @agent_client.stub!(:deploy_artifact).and_return({ 'artifact_id' => 1 })
      @deployment.stub!(:artifact).and_return(@artifact)
      @deployment.stub!(:artifact_version).and_return(@artifact_version)
      @deployment.stub!(:environment).and_return(@environment)
      @instance.stub!(:agent_client).and_return(@agent_client)
      @artifact.stub!(:service).and_return(@service)
      @deployment.stub!(:instances_for_deploy).and_return([@instance])
      @environment.stub!(:ready_for_deployments?).and_return(true)
    end

    it "should not deploy if the environment is not ready" do
      @environment.stub!(:ready_for_deployments?).and_return(false)
      @deployment.should_not_receive(:instances_for_deploy)
      @deployment.deploy
    end

    it "should attempt to deploy the artifact_version" do
      @agent_client.should_receive(:deploy_artifact).with(@artifact_version)
      @deployment.deploy
    end

    it "should store the remote artifact id" do
      @deployment.deploy
      @deployment.agent_artifact_identifier.should == 1
    end

    it "should mark the deployment as deployed once" do
      instance2 = Factory.build(:instance)
      instance2.stub!(:agent_client).and_return(@agent_client)
      @deployment.stub!(:instances_for_deploy).and_return([@instance, instance2])
      @deployment.should_receive(:mark_as_deployed!).once
      @deployment.deploy
    end

    it "should fail! the deployment if client deploy raises" do
      @agent_client.stub!(:deploy_artifact).and_raise(AgentClient::RequestFailedError.new('msg'))
      @deployment.should_receive(:fail!)
      @deployment.deploy
    end

    it "should fail! if the client deploy does not return an artifact_id" do
      @agent_client.stub!(:deploy_artifact).and_return({ })
      @deployment.should_receive(:fail!)
      @deployment.deploy
    end
  end

  describe 'undeploy' do
    before(:each) do
      @artifact = Factory.build(:artifact)
      @artifact_version = Factory.build(:artifact_version)
      @instance = Factory.build(:instance)
      @deployment = Factory.build(:deployment)
      @agent_client = mock(AgentClient)
      @agent_client.stub!(:undeploy_artifact).and_return(true)
      @deployment.stub!(:artifact).and_return(@artifact)
      @deployment.stub!(:artifact_version).and_return(@artifact_version)
      @instance.stub!(:agent_client).and_return(@agent_client)
      @deployment.stub!(:instances_for_deploy).and_return([@instance])
      @deployment.stub!(:agent_artifact_identifier).and_return(1)
      @deployment.current_state = 'deployed'
    end

    it "should ignore failed deployments" do
      @agent_client.should_not_receive(:undeploy)
      @deployment.current_state = 'deploy_failed'
      @deployment.undeploy
    end

    it "should ingore deploying deployments" do
      @agent_client.should_not_receive(:undeploy)
      @deployment.current_state = 'deploying'
      @deployment.undeploy
    end

    it "should call undeploy on the client" do
      @agent_client.should_receive(:undeploy_artifact).with(1)
      @deployment.undeploy
    end

    it "should mark_as_undeployed! once on a successful undeploy" do
      instance2 = Factory.build(:instance)
      instance2.stub!(:agent_client).and_return(@agent_client)
      @deployment.stub!(:instances_for_deploy).and_return([@instance, instance2])
      @deployment.should_receive(:mark_as_undeployed!).once
      @deployment.undeploy
    end

    it "should not mark_as_undeployed! on an unsuccessful undeploy" do
      @agent_client.stub!(:undeploy).and_raise(AgentClient::RequestFailedError.new(''))
      @deployment.should_not_receive(:mark_as_undeployed!)
    end

    it "should catch exceptions from undeploy" do
      @agent_client.stub!(:undeploy).and_raise(AgentClient::RequestFailedError.new(''))
      lambda{
        @deployment.undeploy
      }.should_not raise_error(AgentClient::RequestFailedError)
    end

  end
=end

end
