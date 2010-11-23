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

class StorageVolumesController < ApplicationController
  before_filter :require_user
  before_filter :require_environment
  
  # DELETE /storage_volumes/1
  # DELETE /storage_volumes/1.xml
  def destroy
    get_storage_volume
    if @storage_volume && @storage_volume.can_be_deleted?
      @storage_volume.destroy
      respond_to do |format|
        format.js { render(generate_json_response(:ok,
                                                  :storage_volume=>@storage_volume.to_json,
                                                  :message=>"Deleting #{@storage_volume.volume_identifier}",
                                                  :js => "$('#volume_#{@storage_volume.id}_delete_link').remove()")) }
      end
    else
      message = (@storage_volume && !@storage_volume.can_delete?) ? "Cannot delete volume while it is #{@storage_volume.current_state}." : "Cannot find volume."
      respond_to do |format|
        format.js { render(generate_json_response(:error, :message=>message)) }
      end
    end
  end

  # POST /environments/:environment_id/storage_volumes/1/status.json
  def status
    get_storage_volume
    if @storage_volume
      respond_to do |format|
        format.js { render(generate_json_response(:ok,
                                                  :html => render_to_string(:partial => 'storage_volumes/row',
                                                                            :locals => {:volume => @storage_volume}))) }
      end
    else
      respond_to do |format|
        format.js { render(generate_json_response(:error, :message=>"Cannot find requested volume")) }
      end
    end
  end

  protected
  def require_environment
    @environment = current_user.environments.find(params[:environment_id])
  end

  def get_storage_volume
    @storage_volume = @environment.storage_volumes.find(params[:id])
  end
end
