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
  class Postgresql < Base
    def configure_instance_service(instance_service)
      username_and_password = instance_service.environment.metadata[:postgresql_admin_user] || generate_username_and_password
      config = { :create_admin => username_and_password }
      Rails.logger.debug "AgentServices::Postgresql#configure_instance_service: configuring with #{config.to_json}"
      instance_service.agent_client.configure(config.to_json)
      instance_service.environment.update_attribute(:metadata, :postgresql_admin_user => username_and_password)
      true
    end

    def open_ports
      [5432]
    end

# since we currently onll manage an admin user, a connection string is useless
=begin       
     def url_for_instance_service(instance_service)
       host = instance_service.instance.public_address
       admin_user = instance_service.metadata[:admin_user]
       "jdbc:postgresql://#{host}:5432/postgres?user=#{admin_user[:user]}&password=#{admin_user[:password]}" if !host.blank? and admin_user
     end
=end


    protected
    def generate_username_and_password
      {
        :user => '_' + SecureRandom.hex(30),
        :password => SecureRandom.hex(30)
      }
    end
  end
end
