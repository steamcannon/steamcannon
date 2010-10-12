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
  class Base
    extend ActiveSupport::Memoizable

    def initialize(user)
      @user = user
    end

    def multicast_config(instance)
      {}
    end

    def launch_options(instance)
      {}
    end

    def default_realm
      nil
    end

    def instances_cache_key
      "User#{@user.id}InstancesCache"
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
      instances = @user.cloud.instances.select do |instance|
        instance.state.upcase != 'STOPPED'
      end
      instances.map { |i| {:id => i.id} }
    end

    def managed_instances
      running_instances.select do |instance|
        !Instance.find_by_cloud_id(instance[:id]).nil?
      end
    end

    def runaway_instances
      []
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

  end
end
