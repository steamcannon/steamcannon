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

describe RealmsController do

  before(:each) do
    login
    @realms = []
    mock_cloud.stub!(:realms).and_return(@realms)
    @current_user.stub!(:cloud).and_return( mock_cloud )
    @current_user.stub!(:environments).and_return( Environment )
    mock_environment.stub!(:instances).and_return( @instances )
    Environment.stub!(:find).with("13").and_return( mock_environment )
  end

  def mock_environment(stubs={})
    @mock_environment ||= mock_model(Environment, stubs)
  end

  def mock_cloud(stubs={})
    @mock_cloud ||= mock_model(Cloud, stubs)
  end

  describe "GET index" do
    it "should assign the requested environment as @environment" do
      get :index, :environment_id => "13", :format=>'xml'
      assigns[:environment].should equal(mock_environment)
    end

    it "should scope requests to the current_user" do
      @current_user.should_receive(:environments)
      get :index, :environment_id => "13", :format=>'xml'
    end

    it "should assign the environment's realms as @realms" do
      get :index, :environment_id => "13", :format=>'xml'
      assigns[:realms].should equal(@realms)
    end
  end

  describe "GET show" do
    before(:each) do
      @realm = OpenStruct.new( :name=>'1' )
      @realm.stub!(:first).and_return(@realm)
      @realms.stub!(:select).and_return(@realm)
    end

    it "should assign the requested environment as @environment" do
      get :show, :id => "1", :environment_id => "13", :format => 'xml'
      assigns[:environment].should equal(mock_environment)
    end

    it "should scope requests to the current_user" do
      @current_user.should_receive(:environments)
      get :show, :id => "1", :environment_id => "13", :format => 'xml'
    end

    it "should assign the requested realm as @realm" do
      get :show, :id => "1", :environment_id => "13", :format => 'xml'
      assigns[:realm].should equal(@realm)
    end
  end
end
