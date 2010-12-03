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

    attr_reader :cloud_username, :cloud_password, :last_error

    def initialize(cloud_username, cloud_password)
      @cloud_username = cloud_username
      @cloud_password = cloud_password
    end

    def launch(image_id, opts={})
      client.create_instance(image_id, opts)
    end

    def instance_available?(instance_id)
      i = client.instance(instance_id)
      (i && i.state != "STOPPED") ? i : false
    end

    def instance_terminated?(instance_id)
      instance = client.instance(instance_id)
      instance && instance.state == "STOPPED"
    end

    def terminate instance_id
      i = client.instance(instance_id)
      i ? i.stop! : false
    end

    def method_missing(meth, *args, &block)
      client.__send__(meth, *args, &block)
    end

    # Similar to active_support's #try, but specifically handles
    # backend errors. If there are args, the last arg must be the
    # return value used on error.
    # Example:
    # dc.attempt(:some_method, []) # [] will be returned on error
    def attempt(meth, *args, &block)
      default = args.pop
      begin
        __send__(meth, *args, &block)
      rescue DeltaCloud::API::BackendError => ex
        @last_error = ex
        Rails.logger.info ex.with_trace
        default
      end
    end

    def hardware_profiles
      deltacloud_hardware_profiles.map(&:name)
    end

    def hardware_profile(profile_name)
      deltacloud_hardware_profiles.find { |hwp| hwp.name == profile_name }
    end

    def architecture(hardware_profile)
      profile = deltacloud_hardware_profiles.find do |hwp|
        hwp.name == hardware_profile
      end
      profile.architecture.value
    end

    def name
      Rails.cache.fetch('DeltacloudDriverName') do
        client.driver_name
      end
    end

    def region
      'us-east-1'
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

    protected

    def deltacloud_hardware_profiles
      Rails.cache.fetch('DeltacloudHardwareProfiles') do
        client.hardware_profiles.select do |profile|
          profile.name != 't1.micro'
        end
      end
    end

  end
end
