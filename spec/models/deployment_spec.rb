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

  describe 'undeploy' do
    before(:each) do
      @deployment = Factory.build(:deployment)
      @deployment.current_state = 'deployed'
      @service = mock(Service)
      @deployment.stub!(:service).and_return(@service)
    end

    it "should delegate to the service" do
      @service.should_receive(:undeploy).with(@deployment)
      @deployment.undeploy
    end

  end


end
