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


class ArtifactVersionsController < ApplicationController
  navigation :artifacts
  before_filter :require_user
  before_filter :load_artifact

  # GET /artifact_versions/new
  # GET /artifact_versions/new.xml
  def new
    @artifact_version = @artifact.artifact_versions.new(params[:artifact_version])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @artifact_version }
    end
  end

  def index
    @artifact_versions = @artifact.artifact_versions
    respond_to { |format| format.xml } # only available via API at the moment
  end

  # POST /artifact_versions
  # POST /artifact_versions.xml
  def create
    @artifact_version = @artifact.artifact_versions.new(params[:artifact_version])

    respond_to do |format|
      if @artifact_version.save
        format.html { redirect_to(@artifact, :notice => 'Version was successfully created.') }
        format.xml  { render :xml => @artifact_version, :status => :created, :location => @artifact_version }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @artifact_version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /artifact_versions/1
  # DELETE /artifact_versions/1.xml
  def destroy
    @artifact_version = @artifact.artifact_versions.find(params[:id])
    @artifact_version.destroy

    respond_to do |format|
      format.html { redirect_to(@artifact) }
      format.xml  { head :ok }
    end
  end

  def status
    artifact_version = @artifact.artifact_versions.find(params[:id])
    render :partial => 'artifact_versions/row', :locals => { :artifact_version => artifact_version }
  end
  
  private

  def load_artifact
    @artifact = current_user.artifacts.find(params[:artifact_id])
  end
end
