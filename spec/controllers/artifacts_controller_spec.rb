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

describe ArtifactsController do
  before(:each) do
    login
    @current_user.stub!(:artifacts).and_return(Artifact)
    Artifact.stub!(:all).and_return([])
  end

  def mock_artifact(stubs={})
    # stubs.merge!({:artifact_versions => ArtifactVersion})
    @mock_artifact ||= mock_model(Artifact, stubs)
  end

  describe "GET /artifacts" do
    it "should be successful" do
      get :index
      response.should be_success
    end
  end

  describe "GET /artifacts/1" do
    before(:each) do
      Artifact.stub!(:find).with("37").and_return(mock_artifact)
    end

    it "should be successful" do
      get :show, :id => "37"
      response.should be_success
    end

    it "assigns the request artifact as @artifact" do
      Artifact.should_receive(:find).with("37").and_return(mock_artifact)
      get :show, :id => "37"
      assigns[:artifact].should equal(mock_artifact)
    end
  end

  describe "GET /artifacts/new" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "POST /artifacts" do
    before(:each) do
      @artifact = mock_model(Artifact)
      Artifact.stub!(:new).and_return(@artifact)
    end

    describe "with valid params" do
      before(:each) do
        @artifact.stub!(:save).and_return(true)
      end

      it "should create new artifact" do
        Artifact.should_receive(:new).and_return(@artifact)
        post :create
      end

      it "should have a flash notice" do
        post :create
        flash[:notice].should_not be_blank
      end

      it "should redirect to the artifact show page" do
        post :create
        response.should redirect_to(artifact_path(@artifact))
      end
    end

    describe "with invalid params" do
      before(:each) do
        @artifact.stub!(:save).and_return(false);
      end

      it "should display new form" do
        post :create
        response.should render_template(:new)
      end
    end
  end

  describe "GET /artifacts/:id/edit" do
    before(:each) do
      @artifact = mock_model(Artifact)
      Artifact.stub!(:find).and_return(@artifact)
    end

    it "should be successful" do
      get :edit, :id => "1"
      response.should be_success
    end

    it "should find and return artifact object" do
      Artifact.should_receive(:find).with("1").and_return(@artifact)
      get :edit, :id => "1"
    end
  end

  describe "PUT /artifacts/:id" do
    before(:each) do
      @artifact = mock_model(Artifact)
      Artifact.stub!(:find).with("1").and_return(@artifact)
    end

    describe "with valid params" do
      before(:each) do
        @artifact.stub!(:update_attributes).and_return(true)
      end

      it "should find and return artifact object" do
        Artifact.should_receive(:find).with("1").and_return(@artifact)
        put :update, :id => "1"
      end

      it "should update the artifact object's attributes" do
        @artifact.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should have a flash notice" do
        put :update, :id => "1"
        flash[:notice].should_not be_blank
      end

      it "should redirect to the artifact show page" do
        put :update, :id => "1"
        response.should redirect_to(artifact_path(@artifact))
      end
    end

    describe "with invalid params" do
      before(:each) do
        @artifact.stub!(:update_attributes).and_return(false)
      end

      it "should find and return artifact object" do
        Artifact.should_receive(:find).with("1").and_return(@artifact)
        put :update, :id => "1"
      end

      it "should update the artifact object's attributes" do
        @artifact.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should render the edit form" do
        put :update, :id => "1"
        response.should render_template(:edit)
      end
    end
  end

  describe "DELETE /artifacts/:id" do
    before(:each) do
      @artifact = mock_model(Artifact)
      Artifact.stub!(:find).and_return(@artifact)
      @artifact.stub!(:destroy)
      @artifact.stub!(:name).and_return("my artifact")
    end

    it "should redirect to artifacts index page" do
      delete :destroy, :id => "1"
      response.should redirect_to(artifacts_path)
    end

    it "should have a flash notice" do
      delete :destroy, :id => "1"
      flash[:notice].should_not be_blank
    end
  end

end
