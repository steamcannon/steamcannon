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
    @current_user_session.stub!(:save).and_return( true )
  end

  def mock_cloud(stubs={})
    @mock_cloud ||= mock_model(Cloud, stubs)
  end

  describe "GET index" do
    it "should assign the realms as @realms" do
      get :index, :format=>'xml'
      assigns[:realms].should equal(@realms)
    end
  end

  describe "GET show" do
    before(:each) do
      @realm = OpenStruct.new( :name=>'1' )
      @realm.stub!(:first).and_return(@realm)
      @realms.stub!(:select).and_return(@realm)
    end

    it "should assign the requested realm as @realm" do
      get :show, :id => "1", :format => 'xml'
      assigns[:realm].should equal(@realm)
    end
  end
end
