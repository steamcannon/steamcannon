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

describe AccountRequestsController do

  def mock_account_request(stubs={})
    @mock_account_request ||= mock_model(AccountRequest, stubs.merge(:email => 'email@example.com'))
  end

  before(:each) do
    APP_CONFIG[:signup_mode] = 'invite_only'
  end
  
  context "as a superuser" do
    before(:each) do
      @logged_in_user = mock_model(User, { :superuser? => true, :profile_complete? => true, :email => 'admin@example.com' })
      login_with_user(@logged_in_user)
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

    describe "POST invite" do
      before(:each) do
        @account_request = mock_model(AccountRequest)
        @account_request.stub!(:send_invitation)
        @account_request.stub!(:send_request_notification)
        AccountRequest.stub!(:find).and_return([@account_request])
      end
      
      it "should accept an array of account_request ids" do
        AccountRequest.should_receive(:find).with([1]).and_return([@account_request])
        post :invite, :account_request_ids => [1]
      end

      it "should accept a single account_request id" do
        AccountRequest.should_receive(:find).with([2]).and_return([@account_request])
        post :invite, :account_request_id => 2
      end

      context "sending invitation" do
        it "should call on the account_requests, passing the current hostname from the request and the email of the currently logged in user" do

          request.should_receive(:host).at_least(:once).and_return('the_host')
          @logged_in_user.should_receive(:email).and_return('admin@example.com')
          @account_request.should_receive(:send_invitation).with('the_host', 'admin@example.com')
          post :invite, :account_request_ids => [1]
        end

        it "should use the default_reply_to_address if specified" do
          APP_CONFIG.should_receive(:[]).with(:default_reply_to_address).and_return('anemail@example.com')
          request.should_receive(:host).at_least(:once).and_return('the_host')
          @logged_in_user.should_not_receive(:email)
          @account_request.should_receive(:send_invitation).with('the_host', 'anemail@example.com')
          post :invite, :account_request_ids => [1]
        end
      end


      it "should redirect back to the index" do
        post :invite, :account_request_ids => [1]
        response.should redirect_to(account_requests_url)
      end
      
    end

    describe "POST ignore" do
      before(:each) do
        @account_request = mock_model(AccountRequest)
        @account_request.stub!(:ignore!)
        AccountRequest.stub!(:find).and_return([@account_request])
      end
      
      it "should accept an array of account_request ids" do
        AccountRequest.should_receive(:find).with([1]).and_return([@account_request])
        post :ignore, :account_request_ids => [1]
      end

      it "should accept a single account_request id" do
        AccountRequest.should_receive(:find).with([2]).and_return([@account_request])
        post :ignore, :account_request_id => 2
      end
      
      it "should ignore the account requests" do
        @account_request.should_receive(:ignore!)
        post :ignore, :account_request_ids => [1]
      end

      it "should redirect back to the index" do
        post :ignore, :account_request_ids => [1]
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
        before(:each) do
          @account_request = mock_account_request(:save => true, :send_request_notification => nil)
        end
        
        it "assigns a newly created account_request as @account_request" do
          AccountRequest.stub(:new).with({'these' => 'params'}).and_return(@account_request)
          post :create, :account_request => {:these => 'params'}
          assigns[:account_request].should equal(@account_request)
        end

        it "redirects to the login page" do
          AccountRequest.stub(:new).and_return(@account_request)
          post :create, :account_request => {}
          response.should redirect_to(new_user_session_url)
        end

        
        it "should call send_request_notification on the account_request, passing the current hostname from the request" do
          APP_CONFIG.should_receive(:[]).with(:signup_mode).and_return('invite_only')
          APP_CONFIG.should_receive(:[]).with(:account_request_notification_address).and_return('admin@example.com')
          request.should_receive(:host).at_least(:once).and_return('the_host')
          @account_request.should_receive(:send_request_notification).with('the_host', 'admin@example.com')
          AccountRequest.stub(:new).and_return(@account_request)
          post :create, :account_request => {}
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
