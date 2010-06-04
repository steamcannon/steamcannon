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
        flash[:notice] = 'App successfully uploaded and should be running shortly'
        format.html { redirect_to(@app) }
        format.xml  { render :xml => @app, :status => :created, :location => @app }
      else
        unless cluster.running?
          flash[:error] = 'App uploaded, cluster startup initiated, patience is a virtue'
          cluster.startup
        end
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

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

  def redeploy
    @app = App.find(params[:id])
    @app.redeploy
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

end
