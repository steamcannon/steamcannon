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
  skip_before_filter :require_cloud_profile, :only => [:index, :new, :create]

  new_action.before do
    flash.now[:error] = "You must create at least one cloud profile before continuing." unless current_organization.has_cloud_profiles?
  end

  index.before do
    flash.now[:error] = "Your administrator must create at least one cloud profile before you will be able to create artifacts or environments." unless current_organization.has_cloud_profiles?
  end

  create.flash { "Cloud profile created." }

  update do
    before do
      if  params && params[:cloud_profile]
        if params[:cloud_profile][:password].blank?
          params[:cloud_profile].delete(:password)
        else
          object.password_dirty = true
        end
      end
    end

    flash { "Cloud profile updated." }
  end

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

  index.wants.xml do 
    render :template => 'cloud_profiles/index.xml'
  end

  show.wants.xml do
    render :template => 'cloud_profiles/show.xml'
  end

  protected
  def end_of_association_chain
    current_organization.cloud_profiles
  end

  def build_object
    @object ||= end_of_association_chain.build object_params
  end

end
