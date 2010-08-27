require 'spec_helper'

describe UsersController do

  describe "GET account/new" do

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

  describe "POST account" do
    before(:each) do
      logout
      @user = mock_model(User)
      User.stub!(:new).and_return(@user)
    end

    describe "with valid params" do
      before(:each) do
        @user.stub!(:save).and_return(true)
      end

      it "should create new user" do
        User.should_receive(:new)
        post :create
      end

      it "should redirect to root page" do
        post :create
        response.should redirect_to(root_url)
      end

      it "should have a flash notice" do
        post :create
        flash[:notice].should_not be_blank
      end
    end

    describe "with invalid params" do
      before(:each) do
        @user.stub!(:save).and_return(false)
      end

      it "should display registration form" do
        post :create
        response.should render_template(:new)
      end
    end
  end

  describe "GET account" do
    before(:each) { login }

    it "should be successful" do
      get :show
      response.should be_success
    end
  end

  describe "GET account/edit" do
    before(:each) { login }

    it "should be successful" do
      get :edit
      response.should be_success
    end
  end

  describe "PUT account" do
    before(:each) { login }

    describe "with valid params" do
      before(:each) do
        @current_user.stub!(:update_attributes).and_return(true)
      end

      it "should update the user object's attributes" do
        @current_user.should_receive(:update_attributes).and_return(true)
        put :update
      end

      it "should redirect to the account show page" do
        put :update
        response.should redirect_to(account_url)
      end
    end

    describe "with invalid params" do
      before(:each) do
        @current_user.stub!(:update_attributes).and_return(false);
      end

      it "should update the user object's attrributes" do
        @current_user.should_receive(:update_attributes).and_return(false)
        put :update
      end

      it "should render the edit form" do
        put :update
        response.should render_template(:edit)
      end
    end
  end

  describe "GET index" do
    it "should limit to users visible to the current user" do
      User.should_receive(:visible_to_user).with(@current_user)
      get :index
    end

  end

  describe "edit/update" do
    before(:each) do
      @superuser = Factory.build(:superuser)
      @account_user = Factory.build(:user)
    end

    context "with a superuser logged in" do
      before(:each) do
        login_with_user(@superuser)
        User.stub!(:find).and_return(@account_user)        
      end
    
      it "should allow a superuser to edit another user" do
        get :edit, :id => 1
        response.should render_template(:edit)
      end

      it "should allow a superuser to update another user" do
        post :update, :id => 1, :user => Factory.attributes_for(:user)
        response.should redirect_to(user_path(@account_user))
      end
    end

    context "with a non-superuser logged in" do
      before(:each) do
        login_with_user(@account_user)
        User.stub!(:find).and_return(@superuser)
      end
      
      it "should not allow a non-superuser to edit other users" do
        get :edit, :id => 1
        response.should redirect_to(new_user_session_path)
      end

      it "should not allow a non-superuser to update another user" do
        post :update, :id => 1, :user => Factory.attributes_for(:user)
        response.should redirect_to(new_user_session_path)
      end
    end
  end
  
  describe "assume user" do
    before(:each) do
      @user = mock_model(User, :email => 'email@example.com')
      User.stub!(:find).and_return(@user)
    end
    
    context "functionality" do
      before(:each) do
        login({ }, :superuser? => true)
        UserSession.stub!(:create)
      end

      it "should switch the current user to the new user" do
        UserSession.should_receive(:create).with(@user)
        get :assume_user, :id => 1
      end

      it "should redirect to the dashboard" do
        get :assume_user, :id => 1
        response.should redirect_to(root_path)
      end
    end
    
    context "permissions" do
      it "should not allow a regular user access" do
        login({ }, :superuser? => false)
        get :assume_user, :id => 1
        response.should redirect_to(new_user_session_path)
      end
      
      it "should allow a superuser to access" do
        login({ }, :superuser? => true)
        UserSession.should_receive(:create).with(@user)
        get :assume_user, :id => 1
      end

    end
  end
end
