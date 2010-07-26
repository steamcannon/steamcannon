require 'spec_helper'

describe EnvironmentsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/environments" }.should route_to(:controller => "environments", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/environments/new" }.should route_to(:controller => "environments", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/environments/1" }.should route_to(:controller => "environments", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/environments/1/edit" }.should route_to(:controller => "environments", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/environments" }.should route_to(:controller => "environments", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/environments/1" }.should route_to(:controller => "environments", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/environments/1" }.should route_to(:controller => "environments", :action => "destroy", :id => "1") 
    end
  end
end
