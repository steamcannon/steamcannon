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


class AppVersionsController < ApplicationController
  navigation :artifacts
  before_filter :require_user
  before_filter :load_artifact

  # GET /app_versions/new
  # GET /app_versions/new.xml
  def new
    @app_version = @artifact.app_versions.new(params[:app_version])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app_version }
    end
  end

  # POST /app_versions
  # POST /app_versions.xml
  def create
    @app_version = @artifact.app_versions.new(params[:app_version])

    respond_to do |format|
      if @app_version.save
        format.html { redirect_to(@artifact, :notice => 'Version was successfully created.') }
        format.xml  { render :xml => @app_version, :status => :created, :location => @app_version }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @app_version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /app_versions/1
  # DELETE /app_versions/1.xml
  def destroy
    @app_version = @artifact.app_versions.find(params[:id])
    @app_version.destroy

    respond_to do |format|
      format.html { redirect_to(@artifact) }
      format.xml  { head :ok }
    end
  end

  private

  def load_artifact
    @artifact = current_user.artifacts.find(params[:artifact_id])
  end
end
