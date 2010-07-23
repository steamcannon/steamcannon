require 'spec_helper'

describe User do
  before(:each) do
    @valid_attributes = {
      :email => "test_user@mailinator.com",
      :password => "test_password",
      :password_confirmation => "test_password"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end

  it "should have a cloud_username attribute" do
    User.new.should respond_to(:cloud_username)
  end

  it "should have a cloud password attribute" do
    User.new.should respond_to(:cloud_password)
  end
end
