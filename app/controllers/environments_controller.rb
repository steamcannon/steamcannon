class EnvironmentsController < ApplicationController
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
        format.html { redirect_to(environments_path, :notice => 'Environment was successfully created.') }
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
        format.html { redirect_to(environments_path, :notice => 'Environment was successfully updated.') }
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
end
