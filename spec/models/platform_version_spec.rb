require 'spec_helper'

describe PlatformVersion do
  before(:each) do
    @valid_attributes = {
      :version_number => "value for version_number",
      :platform_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    PlatformVersion.create!(@valid_attributes)
  end

  it "should have a version_number attribute" do
    PlatformVersion.new.should respond_to(:version_number)
  end

  it "should belong to a platform" do
    PlatformVersion.new.should respond_to(:platform)
  end

  it "should have many images" do
    PlatformVersion.new.should respond_to(:images)
  end
end
