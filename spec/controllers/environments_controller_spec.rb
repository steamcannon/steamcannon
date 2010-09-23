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

describe EnvironmentsController do
  before(:each) do
    login
    @current_user.stub!(:environments).and_return(Environment)
  end

  def mock_environment(stubs={})
    @mock_environment ||= mock_model(Environment, stubs)
  end

  describe "GET index" do
    it "assigns all environments as @environments" do
      Environment.stub(:find).with(:all).and_return([mock_environment])
      get :index
      assigns[:environments].should == [mock_environment]
    end

    it "should only show the current user's environments" do
      @current_user.should_receive(:environments)
      get :index
    end
  end

  describe "GET show" do
    it "assigns the requested environment as @environment" do
      Environment.stub(:find).with("37").and_return(mock_environment)
      get :show, :id => "37"
      assigns[:environment].should equal(mock_environment)
    end
  end

  describe "GET new" do
    it "assigns a new environment as @environment" do
      Environment.stub(:new).and_return(mock_environment)
      get :new
      assigns[:environment].should equal(mock_environment)
    end
  end

  describe "GET edit" do
    it "assigns the requested environment as @environment" do
      Environment.stub(:find).with("37").and_return(mock_environment)
      get :edit, :id => "37"
      assigns[:environment].should equal(mock_environment)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created environment as @environment" do
        Environment.stub(:new).with({'these' => 'params'}).and_return(mock_environment(:save => true))
        post :create, :environment => {:these => 'params'}
        assigns[:environment].should equal(mock_environment)
      end

      it "redirects to the environment" do
        Environment.stub(:new).and_return(mock_environment(:save => true))
        post :create, :environment => {}
        response.should redirect_to(environment_path(mock_environment))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved environment as @environment" do
        Environment.stub(:new).with({'these' => 'params'}).and_return(mock_environment(:save => false))
        post :create, :environment => {:these => 'params'}
        assigns[:environment].should equal(mock_environment)
      end

      it "re-renders the 'new' template" do
        Environment.stub(:new).and_return(mock_environment(:save => false))
        post :create, :environment => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested environment" do
        Environment.should_receive(:find).with("37").and_return(mock_environment)
        mock_environment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :environment => {:these => 'params'}
      end

      it "assigns the requested environment as @environment" do
        Environment.stub(:find).and_return(mock_environment(:update_attributes => true))
        put :update, :id => "1"
        assigns[:environment].should equal(mock_environment)
      end

      it "redirects to the environment" do
        Environment.stub(:find).and_return(mock_environment(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(environment_path(mock_environment))
      end
    end

    describe "with invalid params" do
      it "updates the requested environment" do
        Environment.should_receive(:find).with("37").and_return(mock_environment)
        mock_environment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :environment => {:these => 'params'}
      end

      it "assigns the environment as @environment" do
        Environment.stub(:find).and_return(mock_environment(:update_attributes => false))
        put :update, :id => "1"
        assigns[:environment].should equal(mock_environment)
      end

      it "re-renders the 'edit' template" do
        Environment.stub(:find).and_return(mock_environment(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested environment" do
      Environment.should_receive(:find).with("37").and_return(mock_environment)
      mock_environment.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the environments list" do
      Environment.stub(:find).and_return(mock_environment(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(environments_url)
    end
  end

  describe "POST start" do
    before(:each) do
      Environment.stub!(:find).and_return(mock_environment)
      mock_environment.stub!(:start!)
    end

    it "starts the requested environment" do
      Environment.should_receive(:find).with("37").and_return(mock_environment)
      mock_environment.should_receive(:start!)
      post :start, :id => "37"
    end

    it "redirects to the environments list if no http referer" do
      post :start, :id => "37"
      response.should redirect_to(environments_url)
    end

    it "redirects to http referer if given" do
      request.env["HTTP_REFERER"] = root_url
      post :start, :id => "37"
      response.should redirect_to(root_url)
    end

  end

  describe "POST stop" do
    it "stops the requested environment" do
      Environment.should_receive(:find).with("37").and_return(mock_environment)
      mock_environment.should_receive(:stop!)
      post :stop, :id => "37"
    end
  end
  
  describe "POST clone" do
    describe "with valid params" do
      before(:each) do
        Environment.should_receive( :find ).with( "37" ).and_return( mock_environment )
      end

      it "should clone the requested environment" do
        clone_environment = mock_model( Environment, {:save => true, :current_state= => :stopped, :can_stop? => false} ) 
        mock_environment.should_receive( :clone ).and_return( clone_environment )
        post :clone, :id => "37"
      end
      
      it "should put the cloned environment in the stopped state" do
        clone_environment = mock_model( Environment, {:save => true, :current_state= => :running, :can_stop? => true} ) 
        mock_environment.should_receive( :clone ).and_return( clone_environment )
        clone_environment.should_receive( :stop )
        post :clone, :id => "37"
      end

      it "assigns a newly created environment as @environment" do
        clone_environment = mock_model( Environment, {:save => true, :current_state= => :stopped, :can_stop? => false} ) 
        mock_environment.should_receive( :clone ).and_return( clone_environment )
        post :clone, :id => "37"
        assigns[:environment].should equal( clone_environment )
      end

      it "redirects to the environment" do
        clone_environment = mock_model( Environment, {:save => true, :current_state= => :stopped, :can_stop? => false} ) 
        mock_environment.should_receive( :clone ).and_return( clone_environment )
        post :clone, :id => "37"
        response.should redirect_to( environment_path( clone_environment ) )
      end
    end
    
    describe "with invalid params" do
      before(:each) do
        Environment.should_receive( :find ).with( "37" ).and_return( nil )
      end

      it "does not assign a newly created environment as @environment" do
        post :clone, :id => "37"
        assigns[:environment].should be_nil
      end

      it "redirects to the environment" do
        post :clone, :id => "37"
        response.should redirect_to( environments_url )
      end
    end
  end

end
