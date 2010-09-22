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

describe DeploymentsController do
  before(:each) do
    login
    @current_user.stub!(:deployments).and_return(Deployment)
  end

  def mock_deployment(stubs={})
    stubs.merge!(:artifact => mock_artifact)
    @mock_deployment ||= mock_model(Deployment, stubs)
  end

  def mock_artifact(stubs={})
    @mock_artifact ||= mock_model(Artifact, stubs)
  end

  describe "GET index" do
    it "assigns all deployments as @deployments" do
      Deployment.stub(:find).with(:all).and_return([mock_deployment])
      get :index
      assigns[:deployments].should == [mock_deployment]
    end
  end

  describe "GET show" do
    it "assigns the requested deployment as @deployment" do
      Deployment.stub(:find).with("37").and_return(mock_deployment)
      get :show, :id => "37"
      assigns[:deployment].should equal(mock_deployment)
    end
  end

  describe "GET new" do
    before(:each) do
      Deployment.stub(:new).and_return(mock_deployment)
      mock_deployment.stub!(:datasource).and_return(nil)
      mock_deployment.stub!(:datasource=)
    end

    it "assigns a new deployment as @deployment" do
      get :new
      assigns[:deployment].should equal(mock_deployment)
    end

    it "defaults to local datasource" do
      mock_deployment.should_receive(:datasource=).with("local")
      get :new
    end
  end

  describe "POST create" do
    before(:each) do
      mock_deployment.stub!(:environment).and_return(Environment.new(:name => "test_env",
                                                                     :user => @current_user))
    end

    describe "with valid params" do
      before(:each) do
        mock_deployment.stub!(:save).and_return(true)
      end

      it "assigns a newly created deployment as @deployment" do
        Deployment.stub(:new).with({'these' => 'params'}).and_return(mock_deployment)
        post :create, :deployment => {:these => 'params'}
        assigns[:deployment].should equal(mock_deployment)
      end

      it "redirects to the artifact show page" do
        Deployment.stub(:new).and_return(mock_deployment)
        post :create, :deployment => {}
        response.should redirect_to(artifact_url(mock_deployment.artifact))
      end
    end

    describe "with invalid params" do
      before(:each) do
        mock_deployment.stub!(:save).and_return(false)
      end

      it "assigns a newly created but unsaved deployment as @deployment" do
        Deployment.stub(:new).with({'these' => 'params'}).and_return(mock_deployment)
        post :create, :deployment => {:these => 'params'}
        assigns[:deployment].should equal(mock_deployment)
      end

      it "re-renders the 'new' template" do
        Deployment.stub(:new).and_return(mock_deployment)
        post :create, :deployment => {}
        response.should render_template('new')
      end
    end

  end

  describe "DELETE destroy" do
    it "undeploys the requested deployment" do
      Deployment.should_receive(:find).with("37").and_return(mock_deployment)
      mock_deployment.should_receive(:undeploy)
      delete :destroy, :id => "37"
    end

    it "redirects to the artifact show page" do
      Deployment.stub(:find).and_return(mock_deployment(:undeploy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(artifact_url(mock_deployment.artifact))
    end
  end

end
