require 'spec_helper'

describe "/dashboard/show.html.haml" do
  include DashboardHelper

  it "renders dashboard" do
    render

    response.should have_tag("h1")
  end
end
