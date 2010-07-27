class InstancesController < ApplicationController
  before_filter :require_user

  # GET /instances
  # GET /instances.xml
  def index
    @instances = current_user.cloud.instances

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @instances }
      format.json  { render :json => @instances }
      format.js { render :partial => 'summary', :object => @instances }
    end
  end

  # GET /instances/1
  # GET /instances/1.xml
  def show
    @instance = Instance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @instance }
      format.json  { render :json => @instance }
      format.js  { render :layout => false }
    end
  end

  # GET /instances/new
  # GET /instances/new.xml
  def new
    @instance = Instance.new(params)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @instance }
    end
  end

  # POST /instances
  # POST /instances.xml
  def create
    @instance = Instance.new(params[:instance])

    respond_to do |format|
      if @instance.save
        flash[:notice] = "Instance was successfully created"
        format.html { redirect_to(@instance) }
        format.xml  { render :xml => @instance, :status => :created, :location => @instance }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /instances/1
  # DELETE /instances/1.xml
  def destroy
    @instance = Instance.find(params[:id])
    @instance.destroy
    flash[:notice] = "Instance #@instance is shutting down"
    respond_to do |format|
      format.html { redirect_to(instances_url) }
      format.xml  { head :ok }
    end
  end

  def shutdown
    cluster.shutdown
    flash[:notice] = 'All instances are shutting down'
    respond_to do |format|
      format.html { redirect_back_or_default(instances_url) }
      format.xml  { head :ok }
    end
  end

end
