require 'spec_helper'

describe AppVersion do
  before(:each) do
    @valid_attributes = {
      :app_id => 1,
      :version_number => 1,
      :archive_file_name => "value for archive_file_name",
      :archive_content_type => "value for archive_content_type",
      :archive_file_size => "value for archive_file_size",
      :archive_updated_at => "value for archive_updated_at"
    }
  end

  it "should create a new instance given valid attributes" do
    app_version = AppVersion.new(@valid_attributes)
    app_version.stub!(:assign_version_number)
    app_version.save!
  end

  it "should belong to an app" do
    AppVersion.new.should respond_to(:app)
  end

  it "should assign a version number before creating" do
    app_version = AppVersion.new(@valid_attributes)
    app_version.should_receive(:assign_version_number)
    app_version.save!
  end

  it "should assign 1 as the first version number" do
    app = mock_model(App, :latest_version_number => nil)
    app_version = AppVersion.new(@valid_attributes)
    app_version.stub!(:app).and_return(app)
    app_version.save!
    app_version.version_number.should be(1)
  end

  it "should return app's name and version as to_s" do
    app = App.new(:name => "test app")
    app_version = AppVersion.new
    app_version.app = app
    app_version.version_number = 2
    app_version.to_s.should eql("test app version 2")
  end
end
