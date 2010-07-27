require 'spec_helper'

describe AppVersionsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/app_versions" }.should route_to(:controller => "app_versions", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/app_versions/new" }.should route_to(:controller => "app_versions", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/app_versions/1" }.should route_to(:controller => "app_versions", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/app_versions/1/edit" }.should route_to(:controller => "app_versions", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/app_versions" }.should route_to(:controller => "app_versions", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/app_versions/1" }.should route_to(:controller => "app_versions", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/app_versions/1" }.should route_to(:controller => "app_versions", :action => "destroy", :id => "1") 
    end
  end
end
