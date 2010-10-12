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

describe CloudInstancesController do
  before(:each) do
    login
  end

  describe "GET index" do
    before(:each) do
      @cloud = mock('cloud')
      @cloud.stub!(:running_instances).and_return([])
      @cloud.stub!(:managed_instances).and_return([])
      @cloud.stub!(:runaway_instances).and_return([])
      @current_user.stub!(:cloud_specific_hacks).and_return(@cloud)
    end

    it "should be successful" do
      get :index
      response.should be_success
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @cloud = mock('cloud')
      @cloud.stub!(:terminate)
      @current_user.should_receive(:cloud).and_return(@cloud)
    end

    it "terminates the requested cloud instance" do
      @cloud.should_receive(:terminate).with('123')
      delete :destroy, :id => "123"
    end

    it "should redirect to cloud instances" do
      delete :destroy, :id => "123"
      response.should redirect_to(cloud_instances_url)
    end
  end
end
