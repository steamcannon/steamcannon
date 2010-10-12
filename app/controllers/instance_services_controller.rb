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

class InstanceServicesController < ApplicationController
  before_filter :require_user
  before_filter :load_environment
  before_filter :load_instance

  def logs
    @instance_service = @instance.instance_services.find(params[:id])
    @type = params[:type] || 'tail'
    respond_to do |format|
      format.html {
        @logs = log_ids
        @log = params[:log] || @logs.first
      }
      format.js {
        @log = params[:log]
        @num_lines = params[:num_lines] || 20
        @offset = params[:offset] || 0
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
