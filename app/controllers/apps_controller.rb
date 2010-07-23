class AppsController < ApplicationController
  navigation :applications
  before_filter :require_user

  # GET /apps
  # GET /apps.xml
  def index
    @apps = App.all(:order => 'created_at desc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @apps }
    end
  end

  # GET /apps/new
  # GET /apps/new.xml
  def new
    @app = App.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app }
    end
  end

  # POST /apps
  # POST /apps.xml
  def create
    @app = App.new(params[:app])

    respond_to do |format|
      if @app.save
        flash[:notice] = "The #{@app.name} app was successfully uploaded"
        format.html { redirect_to apps_path }
        format.xml  { render :xml => @app, :status => :created, :location => @app }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @app = App.find(params[:id])
  end

  def update
    @app = App.find(params[:id])
    respond_to do |format|
      if @app.update_attributes(params[:app])
        flash[:notice] = "The #{@app.name} app was successfully updated"
        format.html { redirect_to apps_path }
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
    @app = App.find(params[:id])
    @app.destroy
    flash[:notice] = "The #{@app.name} app was successfully deleted"
    respond_to do |format|
      format.html { redirect_to apps_path }
      format.xml  { head :ok }
    end
  end

end
