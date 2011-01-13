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

describe PlatformsController do

  describe "when not logged in" do
    before(:each) { logout }
    it "should require login" do
      get :new
      response.should redirect_to(new_user_session_path)
    end
  end

  describe "when logged in" do
    before(:each) do
      @superuser = Factory.build(:superuser)
      @account_user = Factory.build(:user)
    end

    describe "GET new" do
      it "should redirect to login if user is not superuser" do
        login_with_user(@account_user)
        get :new
        response.should be_redirect
      end

      it "should require superuser" do
        login_with_user(@superuser)
        get :new
        response.should render_template(:new)
      end
    end


    describe "GET index" do
      it "should not require superuser" do
        login_with_user(@account_user)
        get :index
        response.should render_template(:index)
      end
    end
    
  end
  
end


