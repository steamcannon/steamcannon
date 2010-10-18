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

    def launch(image_id, opts={})
      client.create_instance(image_id, opts)
    end

    def instance_available?(instance_id)
      i = client.instance(instance_id)
      (i && i.state != "TERMINATED") ? i : false
    end

    def terminate instance_id
      i = client.instance(instance_id)
      i ? i.stop! : false
    end

    def method_missing(meth, *args, &block)
      if client.respond_to?(meth)
        client.send(meth, *args, &block)
      else
        super
      end
    end

    def hardware_profiles
      Rails.cache.fetch('DeltacloudHardwareProfiles') do
        supported = client.hardware_profiles.select do |hardware_profile|
          hardware_profile.architecture.value == "i386"
        end
        supported.map(&:name)
      end
    end

    def name
      Rails.cache.fetch('DeltacloudDriverName') do
        client.driver_name
      end
    end

    def client
      @client ||= DeltaCloud.new(@cloud_username, @cloud_password, APP_CONFIG[:deltacloud_url])
    end

    def valid_credentials?
      DeltaCloud.valid_credentials?(@cloud_username, @cloud_password, APP_CONFIG[:deltacloud_url])
    end

    def valid_key_name?(key_name)
      key_names = client.keys.map(&:id)
      key_names.include?(key_name)
    end

  end
end
