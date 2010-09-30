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
    # see also: JbossAs#configure_instance
    def configure_instance(instance)
      jboss_service = Service.by_name('jboss_as')
      environment.active_instances_for_service(jboss_service).each do |jboss_instance|
        # we pluck out and configure just the jboss service on the
        # instance instead of all services, since one of those
        # services could be mod_cluster, which would put us in a loop.
        jboss_instance.instance_services.find_by_service_id(jboss_service.id).configure
      end
      true
    end
  end
end
