require 'spec_helper'

describe PlatformVersionImage do
  before(:each) do
    @valid_attributes = {
      :platform_version_id => 1,
      :image_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    PlatformVersionImage.create!(@valid_attributes)
  end
end
