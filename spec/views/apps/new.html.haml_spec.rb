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
      with_tag("textarea#app_description[name=?]", "app[description]")
    end
  end

  it "should have a cancel link" do
    render
    response.should have_tag("a[href=?]", apps_path)
  end
end
