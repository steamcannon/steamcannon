require 'spec_helper'

describe Image do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :cloud_id => "value for cloud_id",
      :image_role_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Image.create!(@valid_attributes)
  end

  it "should have a name attribute" do
    Image.new.should respond_to(:name)
  end

  it "should have a cloud_id attribute" do
    Image.new.should respond_to(:cloud_id)
  end

  it "should belong to an image role" do
    Image.new.should respond_to(:image_role)
  end

  it "should have many platform versions" do
    Image.new.should respond_to(:platform_versions)
  end

  it "should have many instances" do
    Image.new.should respond_to(:instances)
  end
end
