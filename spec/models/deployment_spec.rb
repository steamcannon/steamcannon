require 'spec_helper'

describe Deployment do
  before(:each) do
    @valid_attributes = {
      :app_id => 1,
      :environment_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Deployment.create!(@valid_attributes)
  end
end
