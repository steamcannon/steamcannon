require 'spec_helper'

describe "/cloud_profiles/show.html.haml" do
  include CloudProfilesHelper
  before(:each) do
    assigns[:cloud_profile] = @cloud_profile = stub_model(CloudProfile,
      :cloud_name => "value for cloud_name",
      :provider_name => "value for provider_name",
      :username => "value for username",
      :password => "value for password"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ cloud_name/)
    response.should have_text(/value\ for\ provider_name/)
    response.should have_text(/value\ for\ username/)
    response.should have_text(/value\ for\ password/)
  end
end
