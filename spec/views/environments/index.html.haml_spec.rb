require 'spec_helper'

describe "/environments/index.html.haml" do
  include EnvironmentsHelper

  before(:each) do
    assigns[:environments] = [
      stub_model(Environment,
                 :name => "value for name"
      ),
      stub_model(Environment,
                 :name => "value for name"
      )
    ]
  end

  it "renders a list of environments" do
    render
    response.should have_tag("div.environment_name", "value for name".to_s, 2)
  end

  it "renders a link to create a new environment" do
    render
    response.should have_tag("a[href=?]", new_environment_path)
  end
end
