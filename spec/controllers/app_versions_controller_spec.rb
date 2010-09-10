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

describe AppVersionsController do
  before(:each) do
    login
    @current_user.stub!(:artifacts).and_return(Artifact)
    Artifact.stub!(:find).with("29").and_return(mock_artifact)
  end

  def mock_app_version(stubs={})
    @mock_app_version ||= mock_model(AppVersion, stubs)
  end

  def mock_artifact(stubs={})
    stubs.merge!({:app_versions => AppVersion})
    @mock_artifact ||= mock_model(Artifact, stubs)
  end

  describe "GET new" do
    it "assigns a new app_version as @app_version" do
      AppVersion.stub(:new).and_return(mock_app_version)
      get :new, :artifact_id => "29"
      assigns[:app_version].should equal(mock_app_version)
    end

    it "should redirect to login page if logged out" do
      logout
      AppVersion.stub(:new).and_return(mock_app_version)
      get :new, :artifact_id => "29"
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created app_version as @app_version" do
        AppVersion.stub(:new).with({'these' => 'params'}).and_return(mock_app_version(:save => true))
        post :create, :app_version => {:these => 'params'}, :artifact_id => "29"
        assigns[:app_version].should equal(mock_app_version)
      end

      it "redirects to the app" do
        AppVersion.stub(:new).and_return(mock_app_version(:save => true))
        post :create, :app_version => {}, :artifact_id => "29"
        response.should redirect_to(artifact_url(mock_artifact))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved app_version as @app_version" do
        AppVersion.stub(:new).with({'these' => 'params'}).and_return(mock_app_version(:save => false))
        post :create, :app_version => {:these => 'params'}, :artifact_id => "29"
        assigns[:app_version].should equal(mock_app_version)
      end

      it "re-renders the 'new' template" do
        AppVersion.stub(:new).and_return(mock_app_version(:save => false))
        post :create, :app_version => {}, :artifact_id => "29"
        response.should render_template('new')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested app_version" do
      AppVersion.should_receive(:find).with("37").and_return(mock_app_version)
      mock_app_version.should_receive(:destroy)
      delete :destroy, :id => "37", :artifact_id => "29"
    end

    it "redirects to the app" do
      AppVersion.stub(:find).and_return(mock_app_version(:destroy => true))
      delete :destroy, :id => "1", :artifact_id => "29"
      response.should redirect_to(artifact_url(mock_artifact))
    end
  end

end
