require 'spec_helper'

describe AccountRequestsController do

  def mock_account_request(stubs={})
    @mock_account_request ||= mock_model(AccountRequest, stubs.merge(:email => 'email@example.com'))
  end

  before(:each) do
    APP_CONFIG[:signup_mode] = 'invite_only'
  end
  
  context "as a superuser" do
    before(:each) do
      login_with_user(mock_model(User, { :superuser? => true, :profile_complete? => true }))
    end

    describe "GET index" do
      it "assigns all account_requests as @account_requests" do
        AccountRequest.stub(:find).with(:all).and_return([mock_account_request])
        get :index
        assigns[:account_requests].should == [mock_account_request]
      end
    end

    describe "GET show" do
      it "assigns the requested account_request as @account_request" do
        AccountRequest.stub(:find).with("37").and_return(mock_account_request)
        get :show, :id => "37"
        assigns[:account_request].should equal(mock_account_request)
      end
    end

    describe "GET edit" do
      it "assigns the requested account_request as @account_request" do
        AccountRequest.stub(:find).with("37").and_return(mock_account_request)
        get :edit, :id => "37"
        assigns[:account_request].should equal(mock_account_request)
      end
    end

    describe "PUT update" do

      describe "with valid params" do
        it "updates the requested account_request" do
          AccountRequest.should_receive(:find).with("37").and_return(mock_account_request)
          mock_account_request.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => "37", :account_request => {:these => 'params'}
        end

        it "assigns the requested account_request as @account_request" do
          AccountRequest.stub(:find).and_return(mock_account_request(:update_attributes => true))
          put :update, :id => "1"
          assigns[:account_request].should equal(mock_account_request)
        end

        it "redirects to the account_request" do
          AccountRequest.stub(:find).and_return(mock_account_request(:update_attributes => true))
          put :update, :id => "1"
          response.should redirect_to(account_request_url(mock_account_request))
        end
      end

      describe "with invalid params" do
        it "updates the requested account_request" do
          AccountRequest.should_receive(:find).with("37").and_return(mock_account_request)
          mock_account_request.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => "37", :account_request => {:these => 'params'}
        end

        it "assigns the account_request as @account_request" do
          AccountRequest.stub(:find).and_return(mock_account_request(:update_attributes => false))
          put :update, :id => "1"
          assigns[:account_request].should equal(mock_account_request)
        end

        it "re-renders the 'edit' template" do
          AccountRequest.stub(:find).and_return(mock_account_request(:update_attributes => false))
          put :update, :id => "1"
          response.should render_template('edit')
        end
      end

    end

    describe "DELETE destroy" do
      it "destroys the requested account_request" do
        AccountRequest.should_receive(:find).with("37").and_return(mock_account_request)
        mock_account_request.should_receive(:destroy)
        delete :destroy, :id => "37"
      end

      it "redirects to the account_requests list" do
        AccountRequest.stub(:find).and_return(mock_account_request(:destroy => true))
        delete :destroy, :id => "1"
        response.should redirect_to(account_requests_url)
      end
    end

  end

  context 'when not logged in' do
    before(:each) do
      logout
    end

    describe "GET new" do
      it "assigns a new account_request as @account_request" do
        AccountRequest.stub(:new).and_return(mock_account_request)
        get :new
        assigns[:account_request].should equal(mock_account_request)
      end
    end


    describe "POST create" do

      describe "with valid params" do
        it "assigns a newly created account_request as @account_request" do
          AccountRequest.stub(:new).with({'these' => 'params'}).and_return(mock_account_request(:save => true))
          post :create, :account_request => {:these => 'params'}
          assigns[:account_request].should equal(mock_account_request)
        end

        it "redirects to the login page" do
          AccountRequest.stub(:new).and_return(mock_account_request(:save => true))
          post :create, :account_request => {}
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved account_request as @account_request" do
          AccountRequest.stub(:new).with({'these' => 'params'}).and_return(mock_account_request(:save => false))
          post :create, :account_request => {:these => 'params'}
          assigns[:account_request].should equal(mock_account_request)
        end

        it "re-renders the 'new' template" do
          AccountRequest.stub(:new).and_return(mock_account_request(:save => false))
          post :create, :account_request => {}
          response.should render_template('new')
        end
      end

    end


  end
end
