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
  before(:each) do
    @valid_attributes = {
      :app_version_id => 1,
      :environment_id => 1,
      :user_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Deployment.create!(@valid_attributes)
  end

  it "should belong to an application" do
    app = App.new
    app_version = AppVersion.new
    app_version.app = app
    deployment = Deployment.new
    deployment.app_version = app_version
    deployment.app.should equal(app)
  end

  it "should be active after creation" do
    deployment = Deployment.create!(@valid_attributes)
    Deployment.active.first.should eql(deployment)
    Deployment.inactive.count.should be(0)
  end

  it "should populate deployed_at after creation" do
    deployment = Deployment.create!(@valid_attributes)
    deployment.deployed_at.should_not be_nil
  end

  it "should populate deployed_by after creation" do
    login
    deployment = Deployment.create!(@valid_attributes)
    deployment.deployed_by.should be(@current_user.id)
  end

  it "should be inactive after undeploying" do
    deployment = Deployment.create!(@valid_attributes)
    deployment.undeploy!
    Deployment.inactive.first.should eql(deployment)
    Deployment.active.count.should be(0)
  end

  it "should populate undeployed_at after undeploying" do
    deployment = Deployment.create!(@valid_attributes)
    deployment.undeploy!
    deployment.undeployed_at.should_not be_nil
  end

  it "should populate undeployed_by after undeploying" do
    login
    deployment = Deployment.create!(@valid_attributes)
    deployment.undeploy!
    deployment.undeployed_by.should be(@current_user.id)
  end
end
