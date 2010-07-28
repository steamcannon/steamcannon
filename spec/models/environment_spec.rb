require 'spec_helper'

describe Environment do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :platform_version_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Environment.create!(@valid_attributes)
  end

  it "should have a name attribute" do
    Environment.new.should respond_to(:name)
  end

  it "should belong to a platform version" do
    Environment.new.should respond_to(:platform_version)
  end

  it "should belong to a platform" do
    platform = Platform.new
    version = PlatformVersion.new(:platform => platform)
    environment = Environment.new(:platform_version => version)
    environment.platform.should eql(platform)
  end

  it "should have many images" do
    environment = Environment.new
    environment.images << Image.new
    environment.images << Image.new
    environment.images.size.should be(2)
  end

  it "should belong to a user" do
    Environment.new.should respond_to(:user)
  end

  it "should not be able to mass-assign user attribute" do
    environment = Environment.new(:user => User.new)
    environment.user.should be_nil
  end

  it "should change status to running when started" do
    env = Environment.new(:name => "test", :status => 'stopped')
    env.start!
    env.status.should eql('running')
  end

  it "should change status to stopped when stopped" do
    env = Environment.new(:name => "test", :status => 'running')
    env.stop!
    env.status.should eql('stopped')
  end

  it "should default to stopped status" do
    Environment.new.status.should eql('stopped')
  end

  it "should destroy all related deployments when stopped" do
    deployment = mock_model(Deployment)
    deployment.should_receive(:destroy)
    env = Environment.new(:name => "test")
    env.deployments << deployment
    env.stop!
  end
end
