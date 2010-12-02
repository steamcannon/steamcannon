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

class InstancesController < ApplicationController
  before_filter :require_user
  before_filter :require_environment

  # GET /environments/:environment_id/instances.json
  def index
    @instances = @environment.instances
    respond_to do |format|
      format.js { render(generate_json_response(:ok, :instances=>@instances.to_json)) }
    end
  end

  # GET /environments/:environment_id/instances/1.json
  def show
    get_instance
    unless @instance.blank?
      respond_to do |format|
        format.js { render(generate_json_response(:ok, :instance=>@instance.to_json)) }
      end
    else
      respond_to do |format|
        format.js { render(generate_json_response(:error, :message=>"Invalid instance")) }
      end
    end
  end

  # POST /environments/:environment_id/instances
  def create
    environment_image = EnvironmentImage.find(params[:environment_image_id])
    instance = environment_image.start_another!
    redirect_to(@environment, :notice => "Instance #{instance.name} is starting")
  end

  # POST /environments/:environment_id/instances/1/stop.json
  def stop
    get_instance
    if @instance && @instance.can_stop?
      @instance.stop!
      respond_to do |format|
        format.js { render(generate_json_response(:ok,
                                                  :instance=>@instance.to_json,
                                                  :message=>"Stopping #{@instance.name} (#{@instance.cloud_id})",
                                                  :js => "$('#instance_#{@instance.id}_stop_link').remove()")) }
      end
    else
      message = (@instance && !@instance.can_stop?) ? "Cannot stop instance while it is #{@instance.current_state}." : "Cannot find instance"
      respond_to do |format|
        format.js { render(generate_json_response(:error, :message=>message)) }
      end
    end
  end

  # POST /environments/:environment_id/instances/1/status.json
  def status
    get_instance
    if @instance
      respond_to do |format|
        format.js { render(generate_json_response(:ok,
                                                  :html => render_to_string(:partial => 'instances/row',
                                                                            :locals => {:instance => @instance}))) }
      end
    else
      respond_to do |format|
        format.js { render(generate_json_response(:error, :message=>"Cannot find requested instance")) }
      end
    end
  end

  protected
  def require_environment
    @environment = current_user.environments.find(params[:environment_id])
  end

  def get_instance
    @instance = @environment.instances.first{|i|i.cloud_id == (params[:id])}
  end
end
