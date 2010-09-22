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

describe DeploymentWatcher do
  before(:each) do
    @deployment_watcher = DeploymentWatcher.new
  end

  it "should deploy deploying deployments" do
    @deployment_watcher.should_receive(:deploy_deploying_deployments)
    @deployment_watcher.run
  end

  it "should attempt to deploy the artifact for a deployment in the deploying state" do
    deployment = mock_model(Deployment)
    deployment.should_receive(:deploy)
    Deployment.stub!(:deploying).and_return([deployment])
    @deployment_watcher.deploy_deploying_deployments
  end

end
