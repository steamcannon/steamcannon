class InstancesController < ApplicationController
  before_filter :require_user
  before_filter :require_environment

  # GET /environments/:environment_id/instances
  # GET /environments/:environment_id/instances.xml
  def index
    @instances = @environment.instances
  end

  # GET /environments/:environment_id/instances/1
  # GET /environments/:environment_id/instances/1.xml
  def show
    get_instance
  end

  # POST /environments/:environment_id/instances/1/stop
  # POST /environments/:environment_id/instances/1/stop.xml
  def stop
    get_instance
  end
  
  
  protected
  def require_environment
    @environment = current_user.environments.find(params[:environment_id])
  end
  
  def get_instance
    @instance = @environment.instances.find(params[:id])    
  end
end