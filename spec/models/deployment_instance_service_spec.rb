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

describe DeploymentInstanceService do
  it { should belong_to :deployment }
  it { should belong_to :instance_service }

  it_should_have_events
  
  describe "confirm_deploy" do
    before(:each) do
      @deployment_instance_service = DeploymentInstanceService.create
      @instance_service = mock(InstanceService)
      @deployment = mock(Deployment)
      @deployment.stub!(:artifact_identifier)
      @deployment_instance_service.stub!(:instance_service).and_return(@instance_service)
      @deployment_instance_service.stub!(:deployment).and_return(@deployment)
    end
    
    it "should move to deployed if the deployment can be confirmed" do
      @instance_service.should_receive(:artifact_metadata).with(@deployment).and_return({ 'name' => 'blah' })
      @deployment_instance_service.confirm_deploy
      @deployment_instance_service.should be_deployed
    end
    
    it "should stay in pending if the deployment can not confirmed" do
      @instance_service.should_receive(:artifact_metadata).with(@deployment).and_return(nil)
      @deployment_instance_service.confirm_deploy
      @deployment_instance_service.should be_pending
    end

    it "should stay in pending if the deployment can not confirmed (and raises)" do
      @instance_service.should_receive(:artifact_metadata).with(@deployment).and_raise(AgentClient::RequestFailedError.new('boom'))
      @deployment_instance_service.confirm_deploy
      @deployment_instance_service.should be_pending
    end

    it "should move to fail if confirmation took too long" do
      @instance_service.should_receive(:artifact_metadata).with(@deployment).and_return(nil)
      @deployment_instance_service.should_receive(:stuck_in_state_for_too_long?).and_return(true)
      @deployment_instance_service.confirm_deploy
      @deployment_instance_service.should be_deploy_failed
    end
  end

  describe "fail!" do
    before(:each) do
      @deployment_instance_service = DeploymentInstanceService.create
    end
    
    it "should move to deploy_failed if pending" do
      @deployment_instance_service.current_state = 'pending'
      @deployment_instance_service.fail!
      @deployment_instance_service.should be_deploy_failed
    end

    it "should move to undeploy_failed if deployed" do
      @deployment_instance_service.current_state = 'deployed'
      @deployment_instance_service.fail!
      @deployment_instance_service.should be_undeploy_failed
    end
  end
end
