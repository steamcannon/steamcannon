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

  it "should be able to deploy an instance" do
    instance = mock_model(Instance)
    Instance.should_receive(:deploy!).and_return(instance)
    image = Image.new(:name => "test_image")
    env_image = EnvironmentImage.new(:image => image,
                                     :hardware_profile => "m1-small",
                                     :num_instances => 1)
    env_image.start!(1)
  end
end
