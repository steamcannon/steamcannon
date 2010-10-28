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

describe Artifact do
  before(:each) do
    @artifact = Factory(:artifact)
  end
  
  it { should belong_to :service }
  it { should have_many :artifact_versions }
  it { should have_many :deployments }
  
  it { should validate_presence_of :name}
  it { should validate_uniqueness_of :name }
  
  it "should belong to a user" do
    @artifact.should respond_to(:user)
  end

  it "should not be able to mass-assign user attribute" do
    artifact = Artifact.new(:user => User.new)
    artifact.user.should be_nil
  end

  describe 'deployment_for_instance_service' do
    before(:each) do
      @instance_service = Factory(:instance_service)
      @deployment = Factory(:deployment)
      @deployment.current_state = 'deployed'
      @instance_service.deployments << @deployment
      @artifact = @deployment.artifact
      @deployment.save
    end
    
    it "should return a deployment if the artifact is deployed there" do
      @artifact.deployment_for_instance_service(@instance_service).should == @deployment
    end
    
    it "should not return the deployment unless it is :deployed" do
      @deployment.update_attribute(:current_state, 'undeployed')
      @artifact.deployment_for_instance_service(@instance).should == nil
    end
  end

  describe "is_deployed?" do
    before(:each) do
      @artifact_version = mock(ArtifactVersion)
      @artifact.stub!(:artifact_versions).and_return([@artifact_version])
    end
    
    it "should return true if any artifact_versions claim to be deployed" do
      @artifact_version.should_receive(:is_deployed?).and_return(true)
      @artifact.is_deployed?.should be_true
    end

    it "should return false if no artifact_versions claim to be deployed" do
      @artifact_version.should_receive(:is_deployed?).and_return(false)
      @artifact.is_deployed?.should_not be_true
    end

  end
end

