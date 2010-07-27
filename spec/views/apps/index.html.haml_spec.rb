require 'spec_helper'

describe "/apps/index.html.haml" do
  include AppsHelper

  before(:each) do
    assigns[:apps] = [
      stub_model(App,
                 :name => "value for name",
                 :description => "value for description"
      ),
      stub_model(App,
                 :name => "value for name",
                 :description => "value for description"
      )
    ]
  end

  it "renders a list of apps" do
    render
    response.should have_tag("div.app_name", "value for name".to_s, 2)
  end

  it "renders a link to upload a new app" do
    render
    response.should have_tag("a[href=?]", new_app_path)
  end
end
