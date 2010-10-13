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

  it { should have_many :deployment_instance_services }
  it { should have_many :instance_services }

  before(:each) do
    login
    @deployment = Factory(:deployment)
    @instance_service = mock(InstanceService)
  end

  it "should belong to an artifact" do
    artifact = Artifact.new
    artifact_version = ArtifactVersion.new
    artifact_version.artifact = artifact
    deployment = Deployment.new
    deployment.artifact_version = artifact_version
    deployment.artifact.should equal(artifact)
  end

  describe 'artifact_identifier' do
    it "should use the agent_artifact_identifier if available" do
      @deployment.agent_artifact_identifier = '77'
      @deployment.artifact_identifier.should == '77'
    end

    it "should use the name of the artifact_version if no agent_artifact_identifier available" do
      artifact_version = mock(ArtifactVersion)
      artifact_version.should_receive(:archive_file_name).and_return('blah.war')
      @deployment.stub!(:artifact_version).and_return(artifact_version)
      @deployment.agent_artifact_identifier = nil
      @deployment.artifact_identifier.should == 'blah.war'
    end
  end

  describe 'creation' do
    before(:each) do
      @environment = Factory(:environment)
      @environment.stub_chain(:instance_services, :running, :for_service).and_return([@instance_service])
      @instance_service.should_receive(:deploy)
      @deployment = Factory(:deployment, :environment => @environment)
    end

    it "should populate deployed_at after moving to :deployed" do
      @deployment.deployed_at.should_not be_nil
    end

    it "should populate deployed_by after deploy" do
      @deployment.deployed_by.should be(@current_user.id)
    end
  end

  describe 'undeploy!' do
    before(:each) do
      @deployment = Factory.build(:deployment)
      @deployment.current_state = 'deployed'
      @instance_service.stub!(:undeploy)
      @deployment.stub!(:instance_services).and_return([@instance_service])
    end

    it "should populate undeployed_at after undeploying" do
      @deployment.undeploy!
      @deployment.undeployed_at.should_not be_nil
    end

    it "should populate undeployed_by after undeploying" do
      @deployment.undeploy!
      @deployment.undeployed_by.should be(@current_user.id)
    end

    it "should undeploy from the instance_services" do
      @instance_service.should_receive(:undeploy).with(@deployment)
      @deployment.undeploy!
    end

  end

  describe "simple_name" do
    it "should strip war suffix" do
      @deployment.should_receive(:artifact_identifier).and_return('app.war')
      @deployment.simple_name.should == 'app'
    end

    it "should strip ear suffix" do
      @deployment.should_receive(:artifact_identifier).and_return('app.ear')
      @deployment.simple_name.should == 'app'
    end

    it "should strip rails suffix" do
      @deployment.should_receive(:artifact_identifier).and_return('app.rails')
      @deployment.simple_name.should == 'app'
    end

    it "should strip rack suffix" do
      @deployment.should_receive(:artifact_identifier).and_return('app.rack')
      @deployment.simple_name.should == 'app'
    end

    it "should return .xml as-is" do
      @deployment.should_receive(:artifact_identifier).and_return('app.xml')
      @deployment.simple_name.should == 'app.xml'
    end
  end

  describe "url" do
    before(:each) do
      @environment = Factory(:environment)
      @deployment.stub!(:environment).and_return(@environment)
    end

    it "should return nil if environment's deployment_base_url is nil" do
      @environment.should_receive(:deployment_base_url).and_return(nil)
      @deployment.url.should be_nil
    end

    it "should concatenate environment's deployment_base_url and simple_name" do
      @environment.should_receive(:deployment_base_url).at_least(:once).and_return('base_url')
      @deployment.should_receive(:simple_name).and_return('simple_name')
      @deployment.url.should == 'base_url/simple_name'
    end
  end


end
