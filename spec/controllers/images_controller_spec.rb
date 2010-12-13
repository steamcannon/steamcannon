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

describe ImagesController do

  before(:each) do
    login_with_http_basic
    @current_user.stub!(:cloud).and_return( mock_cloud )
    @current_user.stub!(:environments).and_return( Environment )
    Environment.stub!(:find).with("13").and_return( mock_environment )
  end

  def mock_environment(stubs={})
    @mock_environment ||= mock_model(Environment, stubs)
  end

  def mock_cloud(stubs={})
    @mock_cloud ||= mock_model(Cloud, stubs)
  end

  describe "GET index" do
    before(:each) do
      @images = []
      mock_environment.stub!(:images).and_return(@images)
    end

    it "should assign the requested environment as @environment" do
      get :index, :environment_id => "13", :format=>'xml'
      assigns[:environment].should equal(mock_environment)
    end

    it "should scope requests to the current_user" do
      @current_user.should_receive(:environments)
      get :index, :environment_id => "13", :format=>'xml'
    end

    it "should assign the environment's images as @images" do
      get :index, :environment_id => "13", :format=>'xml'
      assigns[:images].should equal(@images)
    end

    it "should return 404 status code if the environment is not found" do
      Environment.stub!(:find).with("13").and_raise(ActiveRecord::RecordNotFound)
      get :index, :environment_id => "13", :format=>'xml'
      response.response_code.should == 404
    end
  end

  describe "GET show" do
    before(:each) do
      @image = mock_model(Image)
      @images = [@image]
      mock_environment.stub!(:images).and_return(@images)
      @images.stub(:find).with("1").and_return(@image)
      @cloud_image = mock_model(CloudImage, :cloud_id=>'1')
      @image.stub!(:cloud_images).and_return([@cloud_image])
    end

    it "should assign the requested environment as @environment" do
      get :show, :id => "1", :environment_id => "13", :format => 'xml'
      assigns[:environment].should equal(mock_environment)
    end

    it "should scope requests to the current_user" do
      @current_user.should_receive(:environments)
      get :show, :id => "1", :environment_id => "13", :format => 'xml'
    end

    it "should assign the requested image as @image" do
      get :show, :id => "1", :environment_id => "13", :format => 'xml'
      assigns[:image].should equal(@image)
    end

    it "should assign the requested cloud_image as @cloud_image" do
      get :show, :id => "1", :environment_id => "13", :format => 'xml'
      assigns[:cloud_image].should equal(@cloud_image)
    end

    it "should return 404 status code if the environment is not found" do
      Environment.stub!(:find).with("13").and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "1", :environment_id => "13", :format => 'xml'
      response.response_code.should == 404
    end

    it "should return 404 status code if the image is not found" do
      @images.stub!(:find).with("2").and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "2", :environment_id => "13", :format => 'xml'
      response.response_code.should == 404
    end

  end
end

