require 'spec_helper'

describe DeploymentsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/deployments" }.should route_to(:controller => "deployments", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/deployments/new" }.should route_to(:controller => "deployments", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/deployments/1" }.should route_to(:controller => "deployments", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/deployments/1/edit" }.should route_to(:controller => "deployments", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/deployments" }.should route_to(:controller => "deployments", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/deployments/1" }.should route_to(:controller => "deployments", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/deployments/1" }.should route_to(:controller => "deployments", :action => "destroy", :id => "1") 
    end
  end
end
