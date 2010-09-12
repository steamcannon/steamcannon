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

describe ArtifactVersionsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/artifact_versions" }.should route_to(:controller => "artifact_versions", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/artifact_versions/new" }.should route_to(:controller => "artifact_versions", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/artifact_versions/1" }.should route_to(:controller => "artifact_versions", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/artifact_versions/1/edit" }.should route_to(:controller => "artifact_versions", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/artifact_versions" }.should route_to(:controller => "artifact_versions", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/artifact_versions/1" }.should route_to(:controller => "artifact_versions", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/artifact_versions/1" }.should route_to(:controller => "artifact_versions", :action => "destroy", :id => "1")
    end
  end
end
