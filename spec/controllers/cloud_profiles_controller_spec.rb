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

describe CloudProfilesController do
  before(:each) do
    @user = login()
  end
  
  def mock_cloud_profile(stubs={})
    @mock_cloud_profile ||= mock_model(CloudProfile, stubs)
  end

  describe "GET index" do
    it "assigns all cloud_profiles as @cloud_profiles" do
      @current_organization.stub_chain(:cloud_profiles, :find).and_return([mock_cloud_profile])
      get :index
      assigns[:cloud_profiles].should == [mock_cloud_profile]
    end
  end

  describe "GET show" do
    it "assigns the requested cloud_profile as @cloud_profile" do
      @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
      get :show, :id => "37"
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end
  end

  describe "GET new" do
    before(:each) do
      @user.stub!(:organization_admin?).and_return(true)
      @current_organization.stub_chain(:cloud_profiles, :build).and_return(mock_cloud_profile)
    end
    
    it "assigns a new cloud_profile as @cloud_profile" do
      get :new
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      get :new
      response.should redirect_to(new_user_session_url)
    end

  end

  describe "GET edit" do
    it "assigns the requested cloud_profile as @cloud_profile" do
      @user.stub!(:organization_admin?).and_return(true)
      @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
      get :edit, :id => "37"
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      get :edit, :id => '1'
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "POST create" do
    before(:each) do
      @user.stub!(:organization_admin?).and_return(true)
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      post :create
      response.should redirect_to(new_user_session_url)
    end

    describe "with valid params" do
      it "assigns a newly created cloud_profile as @cloud_profile" do
      @current_organization.stub_chain(:cloud_profiles, :build).with({'these' => 'params'}).and_return(mock_cloud_profile(:save => true))
        post :create, :cloud_profile => {:these => 'params'}
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end
      
      it "redirects to the created cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :build).and_return(mock_cloud_profile(:save => true))
        post :create, :cloud_profile => {}
        response.should redirect_to(cloud_profile_url(mock_cloud_profile))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved cloud_profile as @cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :build).with({'these' => 'params'}).and_return(mock_cloud_profile(:save => false))
        post :create, :cloud_profile => {:these => 'params'}
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "re-renders the 'new' template" do
        @current_organization.stub_chain(:cloud_profiles, :build).and_return(mock_cloud_profile(:save => false))
        post :create, :cloud_profile => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do
    before(:each) do
      @user.stub!(:organization_admin?).and_return(true)
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      put :update, :id => '1'
      response.should redirect_to(new_user_session_url)
    end

    describe "with valid params" do
      it "updates the requested cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
        mock_cloud_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :cloud_profile => {:these => 'params'}
      end

      it "assigns the requested cloud_profile as @cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:update_attributes => true))
        put :update, :id => "1"
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "redirects to the cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(cloud_profile_url(mock_cloud_profile))
      end
    end

    describe "with invalid params" do
      it "updates the requested cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
        mock_cloud_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :cloud_profile => {:these => 'params'}
      end

      it "assigns the cloud_profile as @cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:update_attributes => false))
        put :update, :id => "1"
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "re-renders the 'edit' template" do
        @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    before(:each) do
      @user.stub!(:organization_admin?).and_return(true)
    end
    
    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      delete :update, :id => '1'
      response.should redirect_to(new_user_session_url)
    end

    it "destroys the requested cloud_profile" do
      @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
      mock_cloud_profile.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the cloud_profiles list" do
      @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(cloud_profiles_url)
    end
  end


  describe 'validate_cloud_credentials' do
    before(:each) do
      @user = login
      @user.stub!(:organization_admin?).and_return(true)
      @client = mock(Cloud::Deltacloud)
      @cloud_profile = mock_model(CloudProfile)
      @cloud_profile.stub!(:cloud).and_return(@client)
      @controller.stub!(:object).and_return(@cloud_profile)
      @client.stub!(:attempt).and_return(true)
    end

    it "should validate" do
      @client.should_receive(:attempt).with(:valid_credentials?, false)
      get :validate_cloud_credentials
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      get :validate_cloud_credentials
      response.should redirect_to(new_user_session_url)
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
      @cloud_profile.should_receive(:password=).with("pw")
      @cloud_profile.should_receive(:username=).with("uname")
      get :validate_cloud_credentials, :password => 'pw', :username => 'uname'
    end
  end

end
