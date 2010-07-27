require 'spec_helper'

describe DashboardController do
  before(:each) { login }

  describe "GET dashboard/show" do
    before(:each) do
      @current_user.stub!(:deployments).and_return(Deployment)
      @current_user.stub!(:environments).and_return(Environment)
    end

    it "should be successful" do
      get :show
      response.should be_success
    end

    it "should require logging in" do
      logout
      get :show
      response.should redirect_to(new_user_session_url)
    end

    it "assigns all deployments as @deployments" do
      deployment = mock_model(Deployment)
      Deployment.stub(:find).with(:all).and_return([deployment])
      get :show
      assigns[:deployments].should == [deployment]
    end

    it "should only show the current user's deployments" do
      @current_user.should_receive(:deployments)
      get :show
    end
  end

end
