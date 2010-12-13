require 'spec_helper'

describe CloudProfilesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/cloud_profiles" }.should route_to(:controller => "cloud_profiles", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/cloud_profiles/new" }.should route_to(:controller => "cloud_profiles", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/cloud_profiles/1" }.should route_to(:controller => "cloud_profiles", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/cloud_profiles/1/edit" }.should route_to(:controller => "cloud_profiles", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/cloud_profiles" }.should route_to(:controller => "cloud_profiles", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/cloud_profiles/1" }.should route_to(:controller => "cloud_profiles", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/cloud_profiles/1" }.should route_to(:controller => "cloud_profiles", :action => "destroy", :id => "1") 
    end
  end
end
