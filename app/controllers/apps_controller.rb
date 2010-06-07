class AppsController < ApplicationController
  # GET /apps
  # GET /apps.xml
  def index
    @apps = App.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @apps }
    end
  end

  # GET /apps/1
  # GET /apps/1.xml
  def show
    @app = App.find(params[:id])

    respond_to do |format|
      format.html { redirect_to root_path unless @app }
      format.xml  { render :xml => @app }
      format.js  { render :layout => false }
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
        flash[:notice] = "The #{@app} app was successfully deployed"
        format.html { redirect_to(@app) }
        format.xml  { render :xml => @app, :status => :created, :location => @app }
      else
        cluster_check
        format.html { redirect_to(@app) }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.xml
  def destroy
    @app = App.find(params[:id])
    @app.destroy
    flash[:notice] = "The #{@app} app was successfully undeployed"
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

  def redeploy
    @app = App.find(params[:id])
    if cluster_check
      @app.redeploy
      flash[:notice] = "The #{@app} app was successfully redeployed"
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

  private
  
  def cluster_check
    unless cluster.running?
      flash[:error] = "Cluster startup initiated, patience is a virtue"
      cluster.startup
    else
      true
    end
  end

end
