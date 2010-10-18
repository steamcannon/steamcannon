require 'spec_helper'

describe AccountRequestsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/account_requests" }.should route_to(:controller => "account_requests", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/account_requests/new" }.should route_to(:controller => "account_requests", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/account_requests/1" }.should route_to(:controller => "account_requests", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/account_requests/1/edit" }.should route_to(:controller => "account_requests", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/account_requests" }.should route_to(:controller => "account_requests", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/account_requests/1" }.should route_to(:controller => "account_requests", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/account_requests/1" }.should route_to(:controller => "account_requests", :action => "destroy", :id => "1") 
    end
  end
end
