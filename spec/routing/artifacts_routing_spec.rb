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
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/artifacts" }.should route_to(:controller => "artifacts", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/artifacts/new" }.should route_to(:controller => "artifacts", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/artifacts/1" }.should route_to(:controller => "artifacts", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/artifacts/1/edit" }.should route_to(:controller => "artifacts", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/artifacts" }.should route_to(:controller => "artifacts", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/artifacts/1" }.should route_to(:controller => "artifacts", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/artifacts/1" }.should route_to(:controller => "artifacts", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #status" do
      { :post => '/artifacts/1/status' }.should route_to(:controller => 'artifacts', :action => 'status', :id => '1')
    end
  end
end
