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
end
