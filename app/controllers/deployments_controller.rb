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


class DeploymentsController < ApplicationController
  navigation :deployments
  before_filter :require_user
  before_filter :find_environment

  # GET /deployments
  # GET /deployments.xml
  def index
    @deployments = @environment.deployments.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  # index.xml.haml
    end
  end

  # GET /deployments/1
  # GET /deployments/1.xml
  def show
    @deployment = @environment.deployments.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  # show.xml.haml
    end
  end

  # GET /deployments/new
  # GET /deployments/new.xml
  def new
    @deployment = @environment.deployments.new(params[:deployment])
    @deployment.datasource ||= "local"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @deployment }
    end
  end

  # POST /deployments
  # POST /deployments.xml
  def create
    @deployment = @environment.deployments.new(params[:deployment])
    @deployment.user = current_user

    respond_to do |format|
      if @deployment.save
        @deployment.environment.start! if @deployment.environment.stopped?
        format.html { redirect_to(@deployment.environment, :notice => 'Artifact was queued for deployment') }
        format.xml  { render :xml => @deployment, :status => :created, :location => @deployment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @deployment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /deployments/1
  # DELETE /deployments/1.xml
  def destroy
    undeploy_and_redirect
  end

  # POST /deployments/1/undeploy
  # POST /deployments/1/undeploy.xml
  def undeploy
    undeploy_and_redirect
  end

  # POST /environments/:id/status.json
  def status
    @deployment = @environment.deployments.find(params[:id])
    render(:partial => "deployments/service_list", :locals => { :deployment => @deployment }) 
  end

  protected
  def find_environment
    @environment = current_user.environments.find(params[:environment_id])
  end

  def undeploy_and_redirect
    @deployment = @environment.deployments.find(params[:id])
    @deployment.undeploy!

    respond_to do |format|
      format.html { redirect_back_or_default(@deployment.artifact, :notice => 'Artifact was queued for undeployment.') }
      format.xml  { head :ok }
    end
  end

end
