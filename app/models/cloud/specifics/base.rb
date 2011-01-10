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
  module Specifics
    class Base
      extend ActiveSupport::Memoizable

      # this is a hack - it would be better to have the cloud specific
      # classes register themselves
      AVAILABLE_CLOUDS = {
        :ec2 => {
          :name => :ec2,
          :display_name => 'Amazon EC2',
          :providers => %w{ us-east-1 us-west-1 eu-west-1 ap-southeast-1 }
        }
      }

      class << self
        def cloud_specifics(name, profile)
          "Cloud::Specifics::#{name.camelize}".constantize.new(profile)
        end

        def available_clouds
          AVAILABLE_CLOUDS
        end
      end


      def initialize(cloud_profile)
        @cloud_profile = cloud_profile
      end

      def multicast_config(instance)
        {}
      end

      def launch_options(instance)
        {}
      end

      def instances_cache_key
        "CloudProfile#{@cloud_profile.id}InstancesCache"
      end

      def instances_summary(force_refresh = false)
        expires_in = force_refresh ? 0.seconds : 5.minutes
        expiring_fetch(instances_cache_key, expires_in) do
          { :running => running_instances.size,
            :managed => managed_instances.size,
            :runaway => runaway_instances.size
          }
        end
      end

      def running_instances
        instances = @cloud_profile.cloud.instances.select do |instance|
          instance.state.upcase != 'STOPPED'
        end
        instances.map do |instance|
          { :id => instance.id,
            :image => instance.image.name,
            :address => instance.public_addresses.first
          }
        end
      rescue => e
        # If we encounter any errors, log them and pretend there are
        # no running instances for now
        log e.with_trace
        []
      end

      def managed_instances
        running_instances.map do |cloud_instance|
          instance = Instance.find_by_cloud_id(cloud_instance[:id])
          if instance.nil?
            nil
          else
            cloud_instance.merge(:image => instance.image.name,
                                 :environment => instance.environment.name,
                                 :user => instance.user.email)
          end
        end.compact
      end

      def runaway_instances
        []
      end

      def instance_run_cost(minutes, hardware_profile, provider)
        0.0
      end

      protected

      def expiring_fetch(cache_key, expires_in)
        cache_value = Rails.cache.read(cache_key)
        if !cache_value || cache_value[:inserted_at] < expires_in.ago.utc
          value = yield
          Rails.cache.write(cache_key, :inserted_at => Time.now.utc, :value => value)
          return value
        else
          return cache_value[:value]
        end
      end

      def log(msg)
        Rails.logger.info("#{self.class}: #{msg}")
      end

    end
  end
end

