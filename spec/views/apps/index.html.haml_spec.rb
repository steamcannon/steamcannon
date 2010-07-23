require 'spec_helper'

describe "/apps/index.html.haml" do
  include AppsHelper

  before(:each) do
    assigns[:apps] = [
      stub_model(App,
                 :name => "value for name",
                 :archive_file_name => "archive.war"
      ),
      stub_model(App,
                 :name => "value for name",
                 :archive_file_name => "archive.war"
      )
    ]
  end

  it "renders a list of apps" do
    render
    response.should have_tag("div.app_name", "value for name".to_s, 2)
    response.should have_tag("div.app_archive_file_name", "archive.war".to_s, 2)
  end

  it "renders a link to upload a new app" do
    render
    response.should have_tag("a[href=?]", new_app_path)
  end
end
