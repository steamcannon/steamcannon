require 'spec_helper'

describe "/dashboard/show.html.haml" do
  include DashboardHelper

  before(:each) do
    assigns[:deployments] = []
    assigns[:environments] = []
  end

  it "renders dashboard" do
    render

    response.should have_tag("h1")
  end
end
