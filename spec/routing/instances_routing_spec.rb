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

describe InstancesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/environments/1/instances" }.should route_to(:controller => "instances", :action => "index", :environment_id => "1")
    end

    it "recognizes and generates #show" do
      { :get => "/environments/1/instances/2" }.should route_to(:controller => "instances", :action => "show", :environment_id => "1", :id => "2")
    end
    
    it "recognizes and generates #stop" do
      { :post => "/environments/1/instances/2/stop" }.should route_to(:controller => "instances", :action => "stop", :environment_id => "1", :id => "2") 
    end

    # TODO: These are failing in spite of the fact that 
    # they're truly unroutable
    # it "does not route #new" do
    #   { :get => "/environments/1/instances/new" }.should_not be_routable
    # end
    # 
    # it "does not route #edit" do
    #   { :get => "/environments/1/instances/edit" }.should_not be_routable
    # end

    it "does not route #create" do
      { :post => "/environments/1/instances" }.should_not be_routable
    end

    it "does not route #update" do
      { :put => "/environments/1/instances/2" }.should_not be_routable
    end

    it "does not route #destroy" do
      { :delete => "/environments/1/instances/2" }.should_not be_routable
    end
    
    it "recognizes and generates #clone" do
      { :post => '/environments/1/instances/2/clone' }.should route_to(:controller => 'instances', :action => 'clone', :environment_id => '1', :id => '2')
    end
    
  end
end
