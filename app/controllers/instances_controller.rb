class InstancesController < ApplicationController
  before_filter :require_user
  before_filter :require_environment

  # GET /environments/:environment_id/instances.json
  def index
    @instances = @environment.instances
    respond_to do |format|
      format.json { render(generate_json_response(:ok, :instances=>@instances.to_json)) }
    end
  end

  # GET /environments/:environment_id/instances/1.json
  def show
    get_instance
    unless @instance.blank?      
      respond_to do |format|
        format.json { render(generate_json_response(:ok, :instance=>@instance.to_json)) }
      end
    else      
      respond_to do |format|
        format.json { render(generate_json_response(:error, :message=>"Invalid instance")) }
      end
    end
  end

  # POST /environments/:environment_id/instances/1/stop.json
  def stop
    get_instance
    if @instance && @instance.can_stop?
      @instance.stop! 
      respond_to do |format|
        format.json { render(generate_json_response(:ok, :instance=>@instance.to_json, :message=>"Stopping #{@instance.name} (#{@instance.cloud_id})")) }
      end
    else      
      message = (@instance && !@instance.can_stop?) ? "Cannot stop instance while it is #{@instance.current_state}." : "Cannot find instance"
      respond_to do |format|
        format.json { render(generate_json_response(:error, :message=>message)) }
      end
    end
  end
  
  # POST /environments/:environment_id/instances/1/status.json
  def status
    get_instance
    if @instance
      respond_to do |format|
        format.json { render(generate_json_response(:ok, :message=>@instance.current_state)) }
      end
    else      
      respond_to do |format|
        format.json { render(generate_json_response(:error, :message=>"Cannot find requested instance")) }
      end
    end
  end
  
  
  protected
  def require_environment
    @environment = current_user.environments.find(params[:environment_id])
  end
  
  def get_instance
    @instance = @environment.instances.find(params[:id])    
  end
end