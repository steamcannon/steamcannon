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

module CloudProfilesHelper
  
  def cloud_profile_options(with_prompt = true)
    accum = ''
    accum << options_for_select('Select...' => nil) if with_prompt
    accum << options_from_collection_for_select(current_user.cloud_profiles, :id, :name_with_details)
    accum
  end

  def cloud_profiles_available_to_environment(environment)
    if environment.new_record?
      current_user.cloud_profiles
    else
      [environment.cloud_profile]
    end
  end

  def cloud_ssh_key_select_options(cloud_profile, environment)
    options = [nil]
    options += cloud_profile.cloud.attempt(:keys, []).collect(&:id) if cloud_profile
    options_for_select(options, environment.try(:ssh_key_name))
  end
  
  def cloud_realm_select_options(cloud_profile, environment)
    options = []
    options += cloud_profile.cloud.attempt(:realms, []).collect(&:id) if cloud_profile
    options_for_select(options, environment.try(:realm))
  end

  def available_clouds
    Cloud::Specifics::Base.available_clouds
  end
  
  def available_cloud_names
    options_for_select(available_clouds.values.collect { |c| [c[:display_name], c[:name]]}.sort_by(&:first))
  end

  def cloud_providers(cloud, selected)
    options_for_select(cloud[:providers], selected)
  end
end
