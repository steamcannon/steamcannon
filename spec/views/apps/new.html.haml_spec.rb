require 'spec_helper'

describe "/apps/new.html.haml" do
  include AppsHelper

  before(:each) do
    assigns[:app] = stub_model(App,
      :new_record? => true,
      :name => "value for name"
    )
  end

  it "renders new app form" do
    render

    response.should have_tag("form[action=?][method=post]", apps_path) do
      with_tag("input#app_name[name=?]", "app[name]")
      with_tag("input#app_archive[name=?]", "app[archive]")
    end
  end
end
