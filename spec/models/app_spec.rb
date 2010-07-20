require 'spec_helper'

describe App do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    App.create!(@valid_attributes)
  end
end
