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
  class JbossAs < Base
    
    def configure_instance(instance)
      config = instance.cloud_specific_hacks.multicast_config
      proxies = environment.active_instances_for_service('mod_cluster')
      unless proxies.empty?
        proxy_list = proxies.inject({}) do |list, proxy_instance|
          dns = proxy_instance.public_dns
          list[dns] = {:host => dns, :port => 80} unless dns.blank?
          list
        end
        config.merge!({:proxy_list => proxy_list})
      end
      instance.agent_client(service).configure(config.to_json)
    end
    
  end
end
