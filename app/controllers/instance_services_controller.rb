class InstanceServicesController < ApplicationController
  before_filter :require_user
  before_filter :load_environment
  before_filter :load_instance

  def logs
    @instance_service = @instance.instance_services.find(params[:id])
    @logs = log_ids
    @log = params[:log] || @logs.first
    @type = params[:type] || 'tail'
    @num_lines = params[:num_lines] || 20
    @offset = params[:offset] || 0
    respond_to do |format|
      format.html
      format.js {
        render(generate_json_response(:ok, tail_response))
      }
    end
  end

  protected
  def load_environment
    @environment = current_user.environments.find(params[:environment_id])
  end

  def load_instance
    @instance = current_user.instances.find(params[:instance_id])
  end

  def tail_response
    @instance_service.agent_client.fetch_log(@log, @num_lines, @offset)
  end

  def log_ids
    @instance_service.agent_client.logs
  end

end
