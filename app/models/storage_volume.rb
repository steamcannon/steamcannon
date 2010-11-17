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

  has_events(:subject_name => lambda{ |v| "#{v.environment.name} Volume (#{v.volume_identifier})" },
             :subject_parent => :environment,
             :subject_owner => lambda { |v| v.environment.user })
  
  belongs_to :environment_image
  belongs_to :instance
  has_one :image, :through => :environment_image
  has_one :environment, :through => :environment_image

  before_destroy :destroy_cloud_volume

  named_scope :pending_destroy, { :conditions => { :pending_destroy => true } }
  
  def prepare(instance)
    update_attribute(:instance, instance)
    ModelTask.async(self, :create_in_cloud)
  end
  
  def attach
    #TODO: handle errors here
    cloud_volume.attach!(:instance_id => instance.cloud_id,
                         :device => image.storage_volume_device) if cloud_volume_is_available?
    attached = cloud_volume_is_attached?
    log_event(:operation => :attach, :status => attached ? :success : :failure, :message => "to #{instance.cloud_id}")
    attached
  end

  def detach
    #TODO: implement
  end
  
  def cloud_volume
    @cloud_volume ||= cloud.storage_volumes(:id => volume_identifier).first unless volume_identifier.blank?
  end

  def cloud_volume_is_available?
    cloud_volume_exists? and
      cloud_volume.state.downcase == 'available'
  end

  def cloud_volume_is_attached?
    cloud_volume_exists? and
      cloud_volume.state.downcase == 'in-use' and
      cloud_volume.instance_id == instance.cloud_id
  end

  def cloud_volume_exists?
    !cloud_volume.nil?
  end

  alias_method :real_destroy, :destroy
  def destroy
    update_attribute(:pending_destroy, true)
  end
  
 protected
  def cloud
    environment.user.cloud
  end

  def create_in_cloud
    return if cloud_volume_is_available?
    #TODO: handle errors here
    @cloud_volume = cloud.create_storage_volume(:realm => environment.default_realm,
                                                :capacity => image.storage_volume_capacity)
    status = :failure
    if @cloud_volume
      update_attribute(:volume_identifier, @cloud_volume.id)
      status = :success
    end
    log_event(:operation => :create_in_cloud, :status => status)
  end
  
  def destroy_cloud_volume
    status = :not_found
    if cloud_volume_exists?
      if cloud_volume_is_available?
        cloud_volume.destroy!
        status = :success
      else
        status = :failure
      end
    end
    log_event(:operation => :destroy_in_cloud, :status => status)
    status != :failure
  end
  
end
