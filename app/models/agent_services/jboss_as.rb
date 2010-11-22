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
    # configures the jboss multicast, sets up the proxy list
    # for mod_cluster if any mod_cluster instances are available
    # and sets admin username and password
    def configure_instance_service(instance_service)
      config = multicast_config(instance_service)
      proxies = proxy_list
      config.merge!({:proxy_list => proxies}) if proxies

      username_and_password = instance_service.environment.metadata[:jboss_as_admin_user] || generate_username_and_password
      config.merge!({:create_admin => username_and_password})
      Rails.logger.debug "AgentServices::JbossAs#configure_instance_service: configuring with #{config.to_json}"
      instance_service.agent_client.configure(config.to_json)
      instance_service.environment.merge_and_update_metadata(:jboss_as_admin_user => username_and_password)

      true
    end

    def open_ports
      [8080]
    end

    def url_for_instance(instance)
      host = instance.public_address
      "http://#{host}:8080"
    end

    def url_for_instance_service(instance_service)
      "#{url_for_instance(instance_service.instance)}/admin-console"
    end

    protected

    def multicast_config(instance_service)
      instance = instance_service.instance
      instance.cloud_specific_hacks.multicast_config(instance)
    end

    def proxy_list
      proxies = environment.instance_services.not_pending.for_service(Service.by_name('mod_cluster'))
      if proxies.empty?
        nil
      else
        proxies.collect(&:instance).inject({}) do |list, proxy_instance|
          dns = proxy_instance.public_address
          list[dns] = {:host => dns, :port => 80} unless dns.blank?
          list
        end
      end
    end

    def generate_username_and_password
      {
        :user => 'admin',
        :password => SecureRandom.hex(15)
      }
    end

  end
end
