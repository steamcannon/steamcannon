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

module AgentServices
  class ModCluster < Base
    # doesn't actually do any mod_cluster configuration, but instead
    # triggers (re)configuration of any jboss services that self
    # configured before the mod_cluster service gets here.
    # see also: JbossAs#configure_instance_service
    def configure_instance_service(instance_service)
      environment.instance_services.running.
        for_service(Service.by_name('jboss_as')).each(&:configure_service)
      true
    end

    def open_ports
      [80]
    end

    def url_for_instance(instance)
      host = instance.public_address
      "http://#{host}"
    end

    def url_for_instance_service(instance_service)
      "#{url_for_instance(instance_service.instance)}/mod_cluster_manager"
    end

  end
end
