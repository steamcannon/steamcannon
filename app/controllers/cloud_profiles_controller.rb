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

class CloudProfilesController < ResourceController::Base
  navigation :cloud_profiles
  
  before_filter :require_user
  before_filter :require_organization_admin, :except => [:index, :show]
  
  def cloud_settings_block
    render :partial => 'environments/cloud_settings', :locals => { :cloud_profile => object }
  end

  # can be called with or without a member record
  def validate_cloud_credentials
    cloud_profile = object || CloudProfile.new
    cloud_profile.username = params[:username] if params[:username]
    cloud_profile.password = params[:password] unless params[:password].blank?
    valid = cloud_profile.cloud.attempt(:valid_credentials?, false)
    render(generate_json_response(valid ? :ok : :error))
  end

  protected
  def end_of_association_chain
    current_organization.cloud_profiles
  end

  def build_object
    @object ||= end_of_association_chain.build object_params
  end

end
