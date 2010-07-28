require 'spec_helper'

describe EnvironmentImage do
  before(:each) do
    @valid_attributes = {
      :environment_id => 1,
      :image_id => 1,
      :hardware_profile => "value for hardware_profile",
      :num_instances => 1
    }
  end

  it "should create a new instance given valid attributes" do
    EnvironmentImage.create!(@valid_attributes)
  end
end
