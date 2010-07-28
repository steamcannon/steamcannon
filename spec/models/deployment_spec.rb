require 'spec_helper'

describe Deployment do
  before(:each) do
    @valid_attributes = {
      :app_version_id => 1,
      :environment_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Deployment.create!(@valid_attributes)
  end

  it "should belong to an application" do
    app = App.new
    app_version = AppVersion.new
    app_version.app = app
    deployment = Deployment.new
    deployment.app_version = app_version
    deployment.app.should equal(app)
  end
end
