require 'spec_helper'

describe DashboardController do
  before(:each) { login }

  describe "GET dashboard/show" do
    it "should be successful" do
      get :show
      response.should be_success
    end

    it "should require logging in" do
      logout
      get :show
      response.should redirect_to(new_user_session_url)
    end
  end

end
