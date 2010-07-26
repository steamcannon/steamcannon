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

  it "should have many platform version images" do
    PlatformVersion.new.should respond_to(:platform_version_images)
  end

  it "should have many images" do
    PlatformVersion.new.should respond_to(:images)
  end

  it "should return the platform's name and its version as to_s" do
    platform = Platform.new(:name => "test platform")
    platform_version = PlatformVersion.new(:version_number => "0.1",
                                           :platform => platform)
    platform_version.to_s.should eql("test platform 0.1")
  end
end
