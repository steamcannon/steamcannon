require 'spec_helper'

describe Environment do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :platform_version_id => 1,
      :user => mock_model(User)
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

  it "should not be able to mass-assign user_id attribute" do
    environment = Environment.new(:user_id => 1)
    environment.user_id.should be_nil
  end

  it "should change status to running when started" do
    env = Environment.new(@valid_attributes.merge(:status => 'stopped'))
    env.start!
    env.status.should eql('running')
  end

  it "should change status to stopped when stopped" do
    env = Environment.new(@valid_attributes.merge(:status => 'running'))
    env.stop!
    env.status.should eql('stopped')
  end

  it "should default to stopped status" do
    Environment.new.status.should eql('stopped')
  end

  it "should undeploy all deployments when stopped" do
    env = Environment.new(@valid_attributes)
    env.deployments << Deployment.new
    env.save!
    env.stop!
    env.deployments.inactive.first.should be_undeployed
  end

  it "should have many instances" do
    Environment.new.should respond_to(:instances)
  end

  it "should stop all instances when stopped" do
    instance = Instance.new
    env = Environment.new(@valid_attributes)
    env.instances << instance
    env.save!
    env.stub_chain(:instances, :active).and_return([instance])
    instance.should_receive(:stop!)
    env.stop!
  end

  it "should not start more instances if already running" do
    env = Environment.new(@valid_attributes.merge(:status => 'running'))
    Instance.should_not_receive(:new)
    env.start!
  end

  it "should start environment images when environment is started" do
    env_image = mock_model(EnvironmentImage, :num_instances => 1)
    env_image.should_receive(:start!)
    env = Environment.new(@valid_attributes)
    env.environment_images << env_image
    env.should_receive(:save!)
    env.start!
  end
end
