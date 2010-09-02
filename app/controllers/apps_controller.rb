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


class AppsController < ApplicationController
  navigation :applications
  before_filter :require_user

  # GET /apps
  # GET /apps.xml
  def index
    @apps = current_user.apps.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @apps }
    end
  end

  # GET /apps/1
  # GET /apps/1.xml
  def show
    @app = current_user.apps.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @app }
    end
  end

  # GET /apps/new
  # GET /apps/new.xml
  def new
    @app = current_user.apps.new
    @app.app_versions << AppVersion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app }
    end
  end

  # POST /apps
  # POST /apps.xml
  def create
    @app = current_user.apps.new(params[:app])

    respond_to do |format|
      if @app.save
        format.html { redirect_to @app, :notice => "The application app was successfully created" }
        format.xml  { render :xml => @app, :status => :created, :location => @app }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @app = current_user.apps.find(params[:id])
  end

  def update
    @app = current_user.apps.find(params[:id])
    respond_to do |format|
      if @app.update_attributes(params[:app])
        format.html { redirect_to @app, :notice => "The application was successfully updated" }
        format.xml  { render :xml => @app, :status => :updated, :location => @app }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.xml
  def destroy
    @app = current_user.apps.find(params[:id])
    @app.destroy
    flash[:notice] = "The #{@app.name} app was successfully deleted"
    respond_to do |format|
      format.html { redirect_to apps_path }
      format.xml  { head :ok }
    end
  end

end
