class AppVersionsController < ApplicationController
  navigation :applications
  before_filter :require_user
  before_filter :load_app

  # GET /app_versions/new
  # GET /app_versions/new.xml
  def new
    @app_version = @app.app_versions.new(params[:app_version])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app_version }
    end
  end

  # POST /app_versions
  # POST /app_versions.xml
  def create
    @app_version = @app.app_versions.new(params[:app_version])

    respond_to do |format|
      if @app_version.save
        format.html { redirect_to(@app, :notice => 'AppVersion was successfully created.') }
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
    @app_version = @app.app_versions.find(params[:id])
    @app_version.destroy

    respond_to do |format|
      format.html { redirect_to(@app) }
      format.xml  { head :ok }
    end
  end

  private

  def load_app
    @app = current_user.apps.find(params[:app_id])
  end
end
