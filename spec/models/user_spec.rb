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

  it "should have a cloud object" do
    User.new.should respond_to(:cloud)
  end

  it "should have many environments" do
    User.new.should respond_to(:environments)
  end

  it "should have many apps" do
    User.new.should respond_to(:apps)
  end

  it "should pass cloud credentials through to cloud object" do
    user = User.new(:cloud_username => 'user', :cloud_password => 'pass')
    Cloud::Deltacloud.should_receive(:new).with('user', 'pass')
    user.cloud
  end

  it "should not allow mass assignment of the superuser column" do
    user = Factory.build(:user)
    user.update_attributes(:superuser => true)
    user.superuser.should == false
  end
  
  context "visible_to_user named_scope" do
    before(:each) do
      @superuser = Factory(:superuser)
      @account_user = Factory(:user)
    end
    
    it "should include all users for a superuser" do
      User.visible_to_user(@superuser).should == [@superuser, @account_user]
    end
    
    it "should only include the given user for an account_user" do
      User.visible_to_user(@account_user).should == [@account_user]
    end
  end
end
