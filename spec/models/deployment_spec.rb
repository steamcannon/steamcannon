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
