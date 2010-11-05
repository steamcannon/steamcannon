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

describe PasswordResetsController do
  
  describe "GET password_resets/new" do

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

  describe "GET password_resets/:id/edit" do

    describe "when not logged in" do
      before(:each) do
        logout
        User.stub!(:find_using_perishable_token).and_return mock_model(User)
      end

      it "should be successful" do
        get :edit, :id=>'123'
        response.should be_success
      end

      it "should render the edit form" do
        get :edit, :id=>'123'
        response.should render_template(:edit)
      end
      
      it "should lookup the user based on the perishable token" do
        User.should_receive(:find_using_perishable_token).with('123')
        get :edit, :id=>'123'
      end
    end

    describe "when logged in" do
      before(:each) { login }

      it "should redirect to root page" do
        get :edit, :id=>'123'
        response.should redirect_to(root_url)
      end
    end
  end
  
  
  describe "POST password_resets" do

    describe "when not logged in" do
      before(:each) do
        logout
        @user = mock_model(User)
        @user.stub!(:send_password_reset_instructions!)
        User.stub!(:find_by_email).with('foo@bar.com').and_return(@user)        
      end
      
      it "should lookup the user based on the email address" do
        User.should_receive(:find_by_email).with('foo@bar.com')
        post :create, :email=>'foo@bar.com'
      end
      
      it "should send password reset instructions" do
        @user.should_receive(:send_password_reset_instructions!)
        post :create, :email=>'foo@bar.com'
      end
      
      it "should redirect to root_path" do
        post :create, :email=>'foo@bar.com'
        response.should redirect_to(root_path)
      end
      
      it "should render password_resets/new if the email address is not found" do
        User.stub!(:find_by_email).with('foo@bar.com').and_return(nil)
        post :create, :email=>'foo@bar.com'
        response.should render_template(:new)
      end
      
    end
    
    describe "when logged in" do
      before(:each) { login }

      it "should redirect to root page" do
        post :create, :email=>'foo@bar.com'
        response.should redirect_to(root_url)
      end
    end
  end
  
  describe "PUT password_resets/:id" do

    describe "when not logged in" do
      before(:each) do
        logout
        @user = mock_model(User)
        @user.stub!(:password=)
        @user.stub!(:password_confirmation=)
        @user.stub!(:save).and_return(true)
        User.stub!(:find_using_perishable_token).and_return @user
      end
      
      it "should redirect to the dashboard" do
        put :update, :id=>'123', :user=>{:password=>'foo', :password_confirmation=>'foo'}
        response.should redirect_to(dashboard_path)
      end

      it "should render the edit form if @user cannot be updated" do
        @user.should_receive(:save).and_return(false)
        put :update, :id=>'123', :user=>{:password=>'foo', :password_confirmation=>'foo'}
        response.should render_template(:edit)
      end
      
      it "should lookup the user based on the perishable token" do
        User.should_receive(:find_using_perishable_token).with('123')
        put :edit, :id=>'123', :user=>{:password=>'foo', :password_confirmation=>'foo'}
      end
      
    end

    describe "when logged in" do
      before(:each) { login }

      it "should redirect to root page" do
        put :update, :id=>'123'
        response.should redirect_to(root_url)
      end
    end

  end
  
end
