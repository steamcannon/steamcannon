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

class CloudInstancesController < ApplicationController

  navigation :instances
  before_filter :require_user

  def index
    cloud = current_user.cloud_specific_hacks
    cloud.instances_summary(true) # force refresh of instances summary
    @running_instances = cloud.running_instances
    @managed_instances = cloud.managed_instances
    @runaway_instances = cloud.runaway_instances
  end

  def destroy
    current_user.cloud.terminate(params[:id])
    redirect_to cloud_instances_path
  end

end
