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


class ArtifactsController < ApplicationController
  navigation :artifacts
  before_filter :require_user

  # GET /artifacts
  # GET /artifacts.xml
  def index
    @artifacts = current_user.artifacts.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @artifacts }
    end
  end

  # GET /artifacts/1
  # GET /artifacts/1.xml
  def show
    @artifact = current_user.artifacts.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @artifact }
    end
  end

  # GET /artifacts/new
  # GET /artifacts/new.xml
  def new
    @artifact = current_user.artifacts.new
    @artifact.artifact_versions << ArtifactVersion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @artifact }
    end
  end

  # POST /artifacts
  # POST /artifacts.xml
  def create
    @artifact = current_user.artifacts.new(params[:artifact])

    respond_to do |format|
      if @artifact.save
        format.html { redirect_to @artifact, :notice => "The artifact was successfully created" }
        format.xml  { render :xml => @artifact, :status => :created, :location => @artifact }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @artifact.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @artifact = current_user.artifacts.find(params[:id])
  end

  def update
    @artifact = current_user.artifacts.find(params[:id])
    respond_to do |format|
      if @artifact.update_attributes(params[:artifact])
        format.html { redirect_to @artifact, :notice => "The artifact was successfully updated" }
        format.xml  { render :xml => @artifact, :status => :updated, :location => @artifact }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @artifact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /artifacts/1
  # DELETE /artifacts/1.xml
  def destroy
    @artifact = current_user.artifacts.find(params[:id])
    @artifact.destroy
    flash[:notice] = "The artifact was successfully deleted"
    respond_to do |format|
      format.html { redirect_to artifacts_path }
      format.xml  { head :ok }
    end
  end

  # POST /artifacts/:id/status.json
  def status
    @artifact = current_user.artifacts.find(params[:id])
    if @artifact
      status = @artifact.deployments.deployed.empty? ? " " : "Running"
      deployments = @artifact.deployments.collect { |d| "#{d.environment.name} (#{d.current_state})" }
      respond_to do |format|
        format.js { render(generate_json_response(:ok, :message=>status, :deployments=>deployments)) }
      end
    else
      respond_to do |format|
        format.js { render(generate_json_response(:error, :message=>"Cannot find requested artifact")) }
      end
    end
  end

end
