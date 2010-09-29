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


module Cloud
  class Deltacloud

    attr_reader :cloud_username, :cloud_password

    def initialize(cloud_username, cloud_password)
      @cloud_username = cloud_username
      @cloud_password = cloud_password
    end

    def instance(id)
      client.instance(id)
    end

    def instances
      client.instances
    end

    def launch(image_id, opts={})
      client.create_instance(image_id, opts)
    end
    
    def instance_available?(instance_id)
      i = client.instance(instance_id)
      i ? i : false
    end

    def terminate instance_id
      i = client.instance(instance_id)
      i ? i.stop! : false
    end

    def hardware_profiles
      @hardware_profiles ||= client.hardware_profiles.map(&:name)
    end

    def name
      client.driver_name
    end

    def client
      @client ||= DeltaCloud.new(@cloud_username, @cloud_password, APP_CONFIG['deltacloud_url'])
    end

  end
end
