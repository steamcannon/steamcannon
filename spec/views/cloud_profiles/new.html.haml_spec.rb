require 'spec_helper'

describe "/cloud_profiles/new.html.haml" do
  include CloudProfilesHelper

  before(:each) do
    assigns[:cloud_profile] = stub_model(CloudProfile,
      :new_record? => true,
      :cloud_name => "value for cloud_name",
      :provider_name => "value for provider_name",
      :username => "value for username",
      :password => "value for password"
    )
  end

  it "renders new cloud_profile form" do
    render

    response.should have_tag("form[action=?][method=post]", cloud_profiles_path) do
      with_tag("input#cloud_profile_cloud_name[name=?]", "cloud_profile[cloud_name]")
      with_tag("input#cloud_profile_provider_name[name=?]", "cloud_profile[provider_name]")
      with_tag("input#cloud_profile_username[name=?]", "cloud_profile[username]")
      with_tag("input#cloud_profile_password[name=?]", "cloud_profile[password]")
    end
  end
end
