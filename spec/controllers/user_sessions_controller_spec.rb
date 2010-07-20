require 'spec_helper'

describe UserSessionsController do

  describe "GET user_session/new" do

    describe "when not logged in" do
      before(:each) { logout }

      it "should be successful" do
        get :new
        response.should be_success
      end

      it "should render the new form" do
        get :new
        response.should render_template(:new)
      end
    end

    describe "when logged in" do
      before(:each) { login }

      it "should redirect to root page" do
        get :new
        response.should redirect_to(root_url)
      end
    end

  end

  describe "POST user_session" do
    before(:each) do
      logout
      UserSession.stub!(:new).and_return(@current_user_session)
    end

    describe "with valid params" do
      before(:each) do
        @current_user_session.stub!(:save).and_return(true)
      end

      it "should redirect to root page" do
        post :create
        response.should redirect_to(root_url)
      end
    end

    describe "with invalid params" do
      before(:each) do
        @current_user_session.stub!(:save).and_return(false)
      end

      it "should display login form" do
        post :create
        response.should render_template(:new)
      end
    end

    describe "DELETE user_session" do
      before(:each) do
        login
        @current_user_session.stub!(:destroy)
      end

      it "should destroy the session" do
        @current_user_session.should_receive(:destroy)
        delete :destroy
      end

      it "should redirect to root page" do
        delete :destroy
        response.should redirect_to(root_url)
      end
    end

  end
end
