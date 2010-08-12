require 'spec_helper'

describe Instance do
  before(:each) do
    @valid_attributes = {
      :environment_id => 1,
      :image_id => 1,
      :name => "value for name",
      :cloud_id => "value for cloud_id",
      :hardware_profile => "value for hardware_profile",
      :status => "value for status",
      :public_dns => "value for public_dns"
    }
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

  it "should populate started_at after creation" do
    instance = Instance.create!(@valid_attributes)
    instance.started_at.should_not be_nil
  end

  it "should populated started_by after creation" do
    login
    instance = Instance.create!(@valid_attributes)
    instance.started_by.should be(@current_user.id)
  end

  it "should be inactive after stopping" do
    instance = Instance.create!(@valid_attributes)
    instance.stop!
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
