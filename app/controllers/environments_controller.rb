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


class EnvironmentsController < ApplicationController
  ARTIFACT_TYPES = [
    :ear, :war, :jar, :rails, :rack, :datasource, :other 
  ]

  navigation :environments
  before_filter :require_user

  # GET /environments
  # GET /environments.xml
  def index
    @environments = current_user.environments.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @environments }
    end
  end

  # GET /environments/1
  # GET /environments/1.xml
  def show
    @environment = current_user.environments.find(params[:id])

    all_deployments = @environment.deployments
    @deployments = {}
    ARTIFACT_TYPES.each do |artifact_type|
      @deployments[ artifact_type ] = all_deployments.select{|e| e.artifact_version.type_key == artifact_type }
    end
    

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @environment }
    end
  end

  # GET /environments/new
  # GET /environments/new.xml
  def new
    @environment = current_user.environments.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @environment }
    end
  end

  # GET /environments/1/edit
  def edit
    @environment = current_user.environments.find(params[:id])
  end

  # POST /environments
  # POST /environments.xml
  def create
    @environment = current_user.environments.new(params[:environment])

    respond_to do |format|
      if @environment.save
        format.html { redirect_to(@environment, :notice => 'Environment was successfully created.') }
        format.xml  { render :xml => @environment, :status => :created, :location => @environment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @environment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /environments/1
  # PUT /environments/1.xml
  def update
    @environment = current_user.environments.find(params[:id])

    respond_to do |format|
      if @environment.update_attributes(params[:environment])
        format.html { redirect_to(@environment, :notice => 'Environment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @environment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /environments/1
  # DELETE /environments/1.xml
  def destroy
    @environment = current_user.environments.find(params[:id])
    @environment.destroy

    respond_to do |format|
      format.html { redirect_to(environments_path, :notice => 'Environment was successfully deleted.') }
      format.xml  { head :ok }
    end
  end

  # POST /environments/1/start
  # POST /environments/1/start.xml
  def start
    @environment = current_user.environments.find(params[:id])
    @environment.start!
    respond_to do |format|
      format.html { redirect_back_or_default(environments_url, :notice => 'Environment was successfully started.') }
      format.xml  { head :ok }
    end
  end

  # POST /environments/1/stop
  # POST /environments/1/stop.xml
  def stop
    @environment = current_user.environments.find(params[:id])
    @environment.stop!
    respond_to do |format|
      format.html { redirect_back_or_default(environments_url, :notice => 'Environment was successfully stopped.') }
      format.xml  { head :ok }
    end
  end
  
  # POST /environments/1/clone
  # POST /environments/1/clone.xml
  def clone
    environment = current_user.environments.find(params[:id])
    unless environment.blank?
      @environment = environment.clone
      @environment.stop if @environment.can_stop?
    end
    respond_to do |format|
      if @environment && @environment.save
        format.html { redirect_to(@environment, :notice => 'Environment was successfully cloned.') }
        format.xml  { render :xml => @environment, :status => :created, :location => @environment }
      else
        format.html { redirect_back_or_default(environments_url, :notice => 'Could not clone. The environment to be cloned was not found.') }
        format.xml  { render :xml => @environment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # POST /environments/:id/status.json
  def status
    @environment = current_user.environments.find(params[:id])
    if @environment
      respond_to do |format|
        format.js { render(generate_json_response(:ok, :message=>@environment.current_state.titleize)) }
      end
    else      
      respond_to do |format|
        format.js { render(generate_json_response(:error, :message=>"Cannot find requested environment")) }
      end
    end
  end
  
  
end
