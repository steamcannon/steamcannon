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

describe DashboardController do


  describe "GET dashboard/show" do
    context 'as an account user' do
      before(:each) do
        login
        @current_user.stub!(:apps).and_return(App)
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
      
      it "assigns all apps as @applications" do
        app = mock_model(App)
        App.stub(:find).with(:all).and_return([app])
        get :show
        assigns[:applications].should == [app]
      end
      
      it "should only show the current user's apps" do
        @current_user.should_receive(:apps)
        get :show
      end

      it "should render the account user dashboard" do
        get :show
        response.should render_template('dashboard/show')
      end
    end

    context 'as a superuser' do
      before(:each) do
        login_with_user(Factory.build(:superuser))
      end

      it "should be successful" do
        get :show
        response.should be_success
      end

      it "should render the superuser dashboard" do
        get :show
        response.should render_template('dashboard/superuser_show')
      end
    end
  end

end
