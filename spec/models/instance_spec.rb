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
end
