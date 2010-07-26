require 'spec_helper'

describe DashboardController do
  describe "routing" do
    it "recognizes and generates #show" do
      { :get => "/dashboard" }.should route_to(:controller => "dashboard", :action => "show")
    end
  end
end
