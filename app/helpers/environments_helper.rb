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


module EnvironmentsHelper

  def platform_version_options(platform_versions)
    platform_versions.collect do |pv|
      [pv.to_s, pv.id]
    end.sort_by(&:first)
  end

  def platform_version_images_json
    PlatformVersion.all.inject({}) do |json, platform_version|
      json[platform_version.id] = platform_version.images
      json
    end.to_json
  end

  def environment_images_json(environment_images)
    environment_images.inject({}) do |json, env_image|
      json[env_image.image_id] = env_image
      json
    end.to_json
  end

  def hardware_profile_options(cloud_profile)
    cloud_profile.cloud.attempt(:hardware_profiles, [])
  end

  def start_environment_link(environment, title = 'Start Environment')
    if environment.storage_volumes.any? { |volume| volume.realm != environment.realm }
      trigger_id = "start_environment_trigger_#{environment.id}"
      accum = link_to title, '#', :id => trigger_id
      accum << render('environments/confirm_start', :environment => environment, :trigger => "##{trigger_id}").html_safe
      accum
    else
      link_to title, start_environment_path(environment), :method => :post
    end
  end
  
  def stop_environment_link(environment, title = "Stop Environment")
    trigger_id = "stop_environment_trigger_#{environment.id}"
    accum = link_to title, '#', :id => trigger_id
    accum << render('environments/confirm_stop', :environment => environment, :trigger => "##{trigger_id}").html_safe
    accum
  end

  def sort_images_by_service_display_order(images)
    images.sort_by do |image|
      image = image.image if image.respond_to?(:image)
      image.services.collect(&:display_order).sort.first
    end
  end
  
  def environments_with_status_for_select
    current_user.environments.all.collect { |ev| ["#{ev.name} (#{ev.current_state})", ev.id ] }
  end
  
  def formatted_run_time(seconds)
    if seconds
      seconds = seconds.to_i
      days = seconds / 1.day
      seconds -= days.days
      hours = seconds / 1.hour
      seconds -= hours.hours
      minutes = seconds / 1.minute
      accum = ""
      accum << "#{days}d " if days > 0
      accum << "#{hours}h " if hours > 0
      accum << "#{minutes}m "
      accum
    else
      'n/a'
    end

  end

  def formatted_run_cost(cost)
    cost ? number_to_currency(cost) : 'n/a'
  end


end
