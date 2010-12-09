#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

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

      context 'in invite_only mode' do
        before(:each) do
          APP_CONFIG[:signup_mode] = 'invite_only'
          @account_request = mock_model(AccountRequest, :email => 'blah@example.com',
                                        :organization => nil)
          @user = mock_model(User, :email= => nil, :organization= => nil)
        end

        it "should redirect to login if signup_mode when no token provided" do
          get :new
          response.should redirect_to(new_user_session_url)
        end

        it "should execute action if a valid token is provided" do
          AccountRequest.should_receive(:find_by_token).with('1234').and_return(@account_request)
          User.should_receive(:new).and_return(@user)
          get :new, :token => '1234'
        end

        it "should redirect to login if signup_mode when an invalid token provided" do
          get :new, :token => 'bad token'
          response.should redirect_to(new_user_session_url)
        end

        it "should store the account_request in an ivar" do
          AccountRequest.should_receive(:find_by_token).with('1234').and_return(@account_request)
          get :new, :token => '1234'
          assigns[:account_request].should == @account_request
        end

        it "should copy organization from account_request" do
          AccountRequest.should_receive(:find_by_token).with('1234').and_return(@account_request)
          User.should_receive(:new).and_return(@user)
          organization = mock_model(Organization)
          @account_request.should_receive(:organization).and_return(organization)
          @user.should_receive(:organization=).with(organization)
          get :new, :token => '1234'
        end
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
      @user.stub!(:organization=)
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

      context 'in invite_only mode' do
        before(:each) do
          APP_CONFIG[:signup_mode] = 'invite_only'
          @account_request = mock_model(AccountRequest)
          @account_request.stub!(:accept!)
          @account_request.stub!(:organization)
        end

        it "should redirect to login if signup_mode when no token provided" do
          post :create
          response.should redirect_to(new_user_session_url)
        end

        it "should execute action if a valid token is provided" do
          mock_association = mock("invited")
          mock_association.should_receive(:find_by_token).with('1234').and_return(@account_request)
          AccountRequest.should_receive(:invited).and_return(mock_association)
          User.should_receive(:new)
          post :create, :token => '1234'
        end

        it "should redirect to login if signup_mode when an invalid token provided" do
          post :create, :token => 'bad token'
          response.should redirect_to(new_user_session_url)
        end

        it "should store the account_request in an ivar" do
          AccountRequest.should_receive(:find_by_token).with('1234').and_return(@account_request)
          post :create, :token => '1234'
          assigns[:account_request].should == @account_request
        end

        it "should accept! the account_request" do
          AccountRequest.should_receive(:find_by_token).with('1234').and_return(@account_request)
          @account_request.should_receive(:accept!)
          post :create, :token => '1234'
        end

        it "should copy organization from account_request" do
          AccountRequest.should_receive(:find_by_token).with('1234').and_return(@account_request)
          organization = mock_model(Organization)
          @account_request.should_receive(:organization).and_return(organization)
          @user.should_receive(:organization=).with(organization)
          post :create, :token => '1234'
        end
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

    it "should set an error message in the flash if the user's profile is not complete'" do
      @current_user.stub!(:profile_complete?).and_return(false)
      get :edit
      flash[:error].should_not be_blank
    end

    it "should NOT set an error message in the flash if the user's profile is not complete'" do
      @current_user.stub!(:profile_complete?).and_return(true)
      get :edit
      flash[:error].should be_blank
    end
  end

  describe "PUT account" do
    before(:each) do
      login
      @current_user.stub!(:cloud_password_dirty=).and_return(true)
    end

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
      User.should_receive(:visible_to_user).with(@current_user).and_return(mock('user_fault', :sorted_by => []))
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

  describe 'validate_cloud_credentials' do
    before(:each) do
      @user = login
      @client = mock(Cloud::Deltacloud)
      @organization = mock(Organization)
      @user.stub!(:cloud).and_return(@client)
      @user.stub!(:organization).and_return(@organization)
      @client.stub!(:attempt).and_return(true)
    end

    it "should validate" do
      @client.should_receive(:attempt).with(:valid_credentials?, false)
      get :validate_cloud_credentials
    end

    context "returned json" do
      it "should have a status of :ok if the credentials are valid" do
        @client.should_receive(:attempt).with(:valid_credentials?, false).and_return(true)
        get :validate_cloud_credentials
        JSON.parse(response.body)['status'].should == 'ok'
      end

      it "should have a status of :error if the credentials are not valid" do
        @client.should_receive(:attempt).with(:valid_credentials?, false).and_return(false)
        get :validate_cloud_credentials
        JSON.parse(response.body)['status'].should == 'error'
      end
    end

    it "should use provided cloud credentials" do
      @organization.should_receive(:cloud_password=).with("pw")
      @organization.should_receive(:cloud_username=).with("uname")
      get :validate_cloud_credentials, :cloud_password => 'pw', :cloud_username => 'uname'
    end
  end

  { "promote" => true, "demote" => false }.each do |action, organization_admin|
    describe action do
      before(:each) do
        @user = mock_model(User, :email => 'email@example.com',
                           :organization_admin= => nil, :save! => nil)
        User.stub!(:find).and_return(@user)
      end

      context "functionality" do
        before(:each) do
          login({ }, :organization_admin? => true)
        end

        it "should set the user's organization admin flag to #{organization_admin}" do
          @user.should_receive(:organization_admin=).with(organization_admin)
          @user.should_receive(:save!)
          post action, :id => 1
        end

        it "should redirect to the users list" do
          post action, :id => 1
          response.should redirect_to(users_path)
        end
      end

      context "permissions" do
        it "should not allow a regular user access" do
          login({ }, :organization_admin? => false)
          post action, :id => 1
          response.should redirect_to(new_user_session_path)
        end

        it "should allow an organization admin to access" do
          login({ }, :organization_admin? => true)
          @user.should_receive(:organization_admin=).with(organization_admin)
          post action, :id => 1
        end
      end
    end
  end

end
