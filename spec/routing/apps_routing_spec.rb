require 'spec_helper'

describe AppsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/apps" }.should route_to(:controller => "apps", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/apps/new" }.should route_to(:controller => "apps", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/apps/1" }.should route_to(:controller => "apps", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/apps/1/edit" }.should route_to(:controller => "apps", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/apps" }.should route_to(:controller => "apps", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/apps/1" }.should route_to(:controller => "apps", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/apps/1" }.should route_to(:controller => "apps", :action => "destroy", :id => "1") 
    end
  end
end
