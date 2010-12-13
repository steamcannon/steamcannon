require 'spec_helper'

describe "/cloud_profiles/index.html.haml" do
  include CloudProfilesHelper

  before(:each) do
    assigns[:cloud_profiles] = [
      stub_model(CloudProfile,
        :cloud_name => "value for cloud_name",
        :provider_name => "value for provider_name",
        :username => "value for username",
        :password => "value for password"
      ),
      stub_model(CloudProfile,
        :cloud_name => "value for cloud_name",
        :provider_name => "value for provider_name",
        :username => "value for username",
        :password => "value for password"
      )
    ]
  end

  it "renders a list of cloud_profiles" do
    render
    response.should have_tag("tr>td", "value for cloud_name".to_s, 2)
    response.should have_tag("tr>td", "value for provider_name".to_s, 2)
    response.should have_tag("tr>td", "value for username".to_s, 2)
    response.should have_tag("tr>td", "value for password".to_s, 2)
  end
end
