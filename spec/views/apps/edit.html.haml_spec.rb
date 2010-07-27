require 'spec_helper'

describe "/apps/edit.html.haml" do
  include AppsHelper

  before(:each) do
    assigns[:app] = stub_model(App,
                               :new_record? => false,
                               :id => 1,
                               :name => "value for name")
  end

  it "renders edit app form" do
    render

    response.should have_tag("form[action=?][method=post]", app_path(assigns[:app])) do
      with_tag("input#app_name[name=?]", "app[name]")
      with_tag("textarea#app_description[name=?]", "app[description]")
    end
  end

  it "should have a cancel link" do
    render
    response.should have_tag("a[href=?]", apps_path)
  end
end
