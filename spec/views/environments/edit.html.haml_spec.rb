require 'spec_helper'

describe "/environments/edit.html.haml" do
  include EnvironmentsHelper

  before(:each) do
    assigns[:environment] =
      stub_model(Environment,
                 :new_record? => false,
                 :id => 1,
                 :name => "value for name")
    @controller.template.stub!(:hardware_profile_options).and_return([])
  end

  it "renders edit environment form" do
    render

    response.should have_tag("form[action=?][method=post]", environment_path(assigns[:environment])) do
      with_tag("input#environment_name[name=?]", "environment[name]")
      with_tag("select#environment_platform_version_id[name=?]",
               "environment[platform_version_id]")
    end
  end
end
