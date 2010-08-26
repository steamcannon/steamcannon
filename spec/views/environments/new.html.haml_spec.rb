require 'spec_helper'

describe "/environments/new.html.haml" do
  include EnvironmentsHelper

  before(:each) do
    assigns[:environment] =
      stub_model(Environment,
                 :new_record? => true,
                 :name => "value for name")
    @controller.template.stub!(:hardware_profile_options).and_return([])
  end

  it "renders new environment form" do
    render

    response.should have_tag("form[action=?][method=post]", environments_path) do
      with_tag("input#environment_name[name=?]", "environment[name]")
      with_tag("select#environment_platform_version_id[name=?]",
               "environment[platform_version_id]")
    end
  end
end
