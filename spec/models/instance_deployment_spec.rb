require 'spec_helper'

describe InstanceDeployment do

  it { should belong_to :instance }
  it { should belong_to :deployment }
  
  before(:each) do
    @valid_attributes = {
      :instance_id => 1,
      :deployment_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    InstanceDeployment.create!(@valid_attributes)
  end
end
