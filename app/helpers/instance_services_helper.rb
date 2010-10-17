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


module InstanceServicesHelper

  def instance_service_link(instance_service)
    url = instance_service.url
    full_name = instance_service.full_name
    if instance_service.running? and url
      link_to(full_name, url)
    else
      full_name
    end
  end

  def additional_instance_service_actions(instance_service)
    if instance_service.name == 'postgresql' and
        instance_service.metadata[:admin_user]
      id = "postgresql_details_trigger_#{instance_service.id}"
      accum = link_to 'Details', '#', :id => id
      accum << render('instance_services/postgresql_details', :instance_service => instance_service, :trigger => "##{id}").html_safe
    end
  end
end
