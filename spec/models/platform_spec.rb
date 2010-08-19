require 'spec_helper'

describe Platform do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    Platform.create!(@valid_attributes)
  end

  it "should have a name attribute" do
    Platform.new.should respond_to(:name)
  end

  it "should have many platform versions" do
    Platform.new.should respond_to(:platform_versions)
  end

  it "should return its name as to_s" do
    Platform.new(:name => "test").to_s.should eql("test")
  end

  describe "yaml loading" do
    before(:each) do
      @yaml_path = File.join(RAILS_ROOT, 'spec/fixtures/platforms')
    end

    it "should support simple platforms" do
      Platform.create_from_yaml(File.join(@yaml_path, 'simple_platform.yml'))
      Platform.find_by_name("Test Platform").should_not be_nil
      # platform = Platform.find_by_name("Test Platform")
      # platform.should_not be_nil
      # platform.platform_versions.should_not be_empty
      # version = PlatformVersion.find_by_version_number(123)
      # version.should_not be_nil
      # version.images.should_not be_empty
      # Image.find_all_by_cloud_id('ami_123').count.should be(1)
    end

    it "should support platform versions" do
      Platform.create_from_yaml(File.join(@yaml_path, 'platform_versions_support.yml'))
      platform = Platform.find_by_name("Test Platform")
      platform.platform_versions.should_not be_empty
      PlatformVersion.find_by_version_number(123).should_not be_nil
    end

    it "should support images" do
      Platform.create_from_yaml(File.join(@yaml_path, 'images_support.yml'))
      version = PlatformVersion.find_by_version_number(123)
      version.should_not be_nil
      version.images.should_not be_empty
      Image.find_all_by_cloud_id('ami_123').count.should be(1)
    end
  end
end
