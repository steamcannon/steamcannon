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


class StorageVolume < ActiveRecord::Base
  belongs_to :environment_image
  belongs_to :instance
  has_one :image, :through => :environment_image
  
  def prepare(instance)
    update_attribute(:instance, instance)
    #TODO: this should be in a task
    create_in_cloud unless cloud_volume_is_available?
  end
  
  def attach
  end

  def detach
  end
  
  def cloud_volume
    @cloud_volume ||= cloud.storage_volumes(:id => volume_identifier).first unless volume_identifier.blank?
  end

  def cloud_volume_is_available?
    !volume_identifier.blank? and
      cloud_volume and
      cloud_volume.state.downcase == 'available'
  end
   
 protected
  def cloud
    environment.user.cloud
  end

  def create_in_cloud
    #TODO: handle errors here
    @cloud_volume = cloud.create_storage_volume(:realm => instance.cloud_specific_hacks.default_realm)
    update_attribute(:volume_identifier, @cloud_volume.id)
    @cloud_volume
  end

end
