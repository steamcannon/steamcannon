require 'spec_helper'
require 'tasks/instance_task'

describe Instance do
  before(:each) do
    @image = mock_model(Image)
    @image.stub!(:cloud_id).and_return("ami-12345")
    @environment = mock_model(Environment)

    @valid_attributes = {
      :environment => @environment,
      :image => @image,
      :name => "value for name",
      :cloud_id => "value for cloud_id",
      :hardware_profile => "value for hardware_profile",
      :public_dns => "value for public_dns"
    }

    InstanceTask.stub(:async)
  end

  it "should create a new instance given valid attributes" do
    Instance.create!(@valid_attributes)
  end

  it "should belong to an environment" do
    Instance.new.should respond_to(:environment)
  end

  it "should belong to an image" do
    Instance.new.should respond_to(:image)
  end

  it "should be active after creation" do
    instance = Instance.create!(@valid_attributes)
    Instance.active.first.should eql(instance)
    Instance.inactive.count.should be(0)
  end

  it "should populate started_at after deploy!" do
    instance = Instance.deploy!(@image, @environment, "test", "small")
    instance.started_at.should_not be_nil
  end

  it "should populate started_by after deploy!" do
    login
    instance = Instance.deploy!(@image, @environment, "test", "small")
    instance.started_by.should be(@current_user.id)
  end

  it "should be pending after deploy!" do
    instance = Instance.deploy!(@image, @environment, "test", "small")
    instance.should be_pending
  end

  it "should be stopping after stop!" do
    instance = Instance.create!(@valid_attributes)
    instance.stop!
    instance.should be_stopping
  end

  it "should populate stopped_at after stop!" do
    instance = Instance.create!(@valid_attributes)
    instance.stop!
    instance.stopped_at.should_not be_nil
  end

  it "should populate stopped_by after stop!" do
    login
    instance = Instance.create!(@valid_attributes)
    instance.stop!
    instance.stopped_by.should be(@current_user.id)
  end

  it "should be inactive after stopped" do
    instance = Instance.create!(@valid_attributes)
    instance.stub!(:terminate_instance)
    instance.stub!(:stopped_in_cloud?).and_return(true)
    instance.stop!
    instance.terminate!
    instance.stopped!
    Instance.inactive.first.should eql(instance)
    Instance.active.count.should be(0)
  end

  it "should generate certs on creation" do
    instance = Instance.create!(@valid_attributes)
    instance.server_key.should_not be_nil
    instance.server_cert.should_not be_nil
    instance.client_key.should_not be_nil
    instance.client_cert.should_not be_nil
  end
end
