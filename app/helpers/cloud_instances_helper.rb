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

module CloudInstancesHelper

  def cloud_instances_header(instance_type)
    { :running => 'Running Instances',
      :managed => 'Managed Instances',
      :runaway => 'Possible Runaway Instances'
    }[instance_type]
  end

  def cloud_instances_header_info(instance_type)
    { :running => 'All instances running under your cloud credentials',
      :managed => 'Running instances managed by this SteamCannon',
      :runaway => 'Running instances orphaned or managed by a different SteamCannon'
    }[instance_type]
  end

  def cloud_instances_actions?(instance_type)
    { :running => false,
      :managed => false,
      :runaway => true
    }[instance_type]
  end
end
