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

module InstancesHelper
  include HardwareProfilesHelper
  def instance_status_for_environment_row(instance)
    case instance.current_state
    when "start_failed"
      msg = "This instance failed to start in the cloud. This may be caused by capacity problems in your selected realm (#{instance.environment.user.default_realm}). Please stop and restart the environment. If the problem persists, choose a different realm by editing your #{link_to 'profile', edit_account_path}."
    end

    text = instance.current_state.titleize
    text << javascript_tag("update_instance_message(#{instance.id}, #{msg.to_json})") if msg

    text
  end

  def instance_details_link(instance)
    unless instance.public_address.blank?
      details = render('instances/details', :instance => instance).html_safe.to_json
      link_to_function('Details', "update_instance_message(#{instance.id}, #{details})")
    end
  end
end
