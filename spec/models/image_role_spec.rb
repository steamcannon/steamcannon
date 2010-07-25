require 'spec_helper'

describe ImageRole do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    ImageRole.create!(@valid_attributes)
  end

  it "should have a name attribute" do
    ImageRole.new.should respond_to(:name)
  end

  it "should have many images" do
    ImageRole.new.should respond_to(:images)
  end
end
