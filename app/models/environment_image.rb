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


class EnvironmentImage < ActiveRecord::Base
  belongs_to :environment
  belongs_to :image
  has_many :storage_volumes
  has_many :instances, :through=>:environment, :conditions=>[ 'image_id=? AND stopped_at IS NULL', '#{image_id}' ]
  validates_presence_of :num_instances
  before_validation :enforce_num_instances

  def start!(instance_number)
    instance = Instance.deploy!(image,
                                environment,
                                "#{image.name} ##{instance_number}",
                                hardware_profile)

    if image.needs_storage_volume?
      storage_volume = storage_volumes[instance_number - 1] || storage_volumes.create
      storage_volume.prepare(instance)
    end

    instance
  end

  def can_start_more?
    image.can_scale_out?
  end

  def start_another!
    instance_number = instances.count + 1
    start!(instance_number)
  end

  protected

  def enforce_num_instances
    self.num_instances = 1 unless image and image.can_scale_out?
  end
end
