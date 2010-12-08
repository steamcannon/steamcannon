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

describe HardwareProfilesController do
  before(:each) do
    login
    @current_user.stub!(:cloud).and_return(mock_cloud)
  end

  def mock_cloud(stubs={})
    @mock_cloud ||= mock_model(Cloud, stubs)
  end

  describe "GET index" do
    it "should assign the user's cloud instance as @cloud" do
      get :index, :format=>'xml'
      assigns[:cloud].should equal(mock_cloud)
    end
  end

  describe "GET show" do
    it "should assign the user's cloud instance as @cloud" do
      get :index, :format => 'xml'
      assigns[:cloud].should equal(mock_cloud)
    end
  end
end
