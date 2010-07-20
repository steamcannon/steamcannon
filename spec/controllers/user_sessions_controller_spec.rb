require 'spec_helper'

describe UserSessionsController do
  before(:each) do
    @user_session = mock_model(UserSession)
    UserSession.stub!(:new).and_return(@user_session)
    UserSession.stub!(:find).and_return(@user_session)
  end

  describe "GET user_session/new" do

    describe "when not logged in" do
      before(:each) do
        @user_session.stub!(:record).and_return(nil)
      end

      it "should be successful" do
        get :new
        response.should be_success
      end

      it "should render the new form" do
        get :new
        response.should render_template('new')
      end
    end

    describe "when logged in" do
      before(:each) do
        @user = mock_model(User)
        @user_session.stub!(:record).and_return(@user)
      end

      it "should redirect to root page" do
        get :new
        response.should redirect_to(root_url)
      end
    end

  end

  describe "POST user_session" do
    before(:each) do
      @user_session.stub!(:record).and_return(nil)
    end

    describe "with valid params" do
      before(:each) do
        @user_session.stub!(:save).and_return(true)
      end

      it "should redirect to root page" do
        post :create
        response.should redirect_to(root_url)
      end
    end

    describe "with invalid params" do
      before(:each) do
        @user_session.stub!(:save).and_return(false)
      end

      it "should display login form" do
        post :create
        response.should render_template("new")
      end
    end

    describe "DELETE user_session" do
      before(:each) do
        @user = mock_model(User)
        @user_session.stub!(:record).and_return(@user)
        @user_session.stub!(:destroy)
      end

      it "should destroy the session" do
        @user_session.should_receive(:destroy)
        delete :destroy
      end

      it "should redirect to root page" do
        delete :destroy
        response.should redirect_to(root_url)
      end
    end

  end
end
