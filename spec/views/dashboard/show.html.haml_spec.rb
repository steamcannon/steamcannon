require 'spec_helper'

describe "/dashboard/show.html.haml" do
  include DashboardHelper

  before(:each) do
    assigns[:applications] = []
    assigns[:environments] = []
  end

  it "renders dashboard" do
    render

    response.should have_tag("#applications")
    response.should have_tag("#environments")
  end
end
