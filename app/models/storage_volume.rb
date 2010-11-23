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
  include AASM
  include StateHelpers

  # we can't use the environment association here, because the initial
  # state gets set before the record is saved, and AR can't access
  # :through assocations if the record does not exist.
  has_events(:subject_name => lambda{ |v| "Volume #{v.volume_identifier}" },
             :subject_parent => lambda { |v| v.environment_image.environment },
             :subject_owner => lambda { |v| v.environment_image.environment.user })
  
  belongs_to :environment_image
  belongs_to :instance
  has_one :image, :through => :environment_image
  has_one :environment, :through => :environment_image

  named_scope :should_exist, :conditions => "current_state != 'creating' AND current_state != 'not_found' AND current_state != 'pending_delete' AND current_state != 'deleted'"
  
  before_destroy :destroy_cloud_volume

  aasm_column :current_state
  aasm_initial_state :creating
  aasm_state :creating
  aasm_state :create_failed
  aasm_state :available
  aasm_state :not_found
  aasm_state :attaching, :enter => :attach_volume
  aasm_state :attached
  aasm_state :attach_failed
  aasm_state :pending_delete
  aasm_state :deleted
  
  aasm_event :available do
    transitions :to => :available, :from => [:creating, :attached, :not_found]
  end

  aasm_event :not_found do
    transitions :to => :not_found, :from => [:creating, :create_failed, :available, :attached, :attach_failed]
  end
  
  aasm_event :fail do
    transitions :to => :create_failed, :from => :creating
  end
  
  aasm_event :attach do
    transitions :to => :attaching, :from => :available, :guard => :cloud_volume_is_available?
    transitions :to => :attached, :from => :attaching, :guard => :cloud_volume_is_attached?
    transitions :to => :attach_failed, :from => [:available, :attaching], :guard => :stuck_in_state_for_too_long?
  end

  #TODO: actually detach instead of just moving back to available
  aasm_event :detach do
    transitions :to => :available, :from => [:attached, :attaching, :attach_failed]
    transitions :to => :not_found, :from => :not_found
  end

  aasm_event :pending_delete do
    transitions :to => :pending_delete, :from => [:creating, :create_failed, :available, :attached, :attach_failed, :not_found]
  end
  
  aasm_event :deleted do
    transitions :to => :deleted, :from => :pending_delete
  end

  def can_be_deleted?
    [:creating, :create_failed, :available, :attach_failed, :not_found].include?(current_state.to_sym)
  end
  
  def prepare(instance)
    update_attribute(:instance, instance)
    ModelTask.async(self, :create_in_cloud)
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
    !cloud_volume.nil? and cloud_volume.state.downcase != 'deleting'
  end

  alias_method :real_destroy, :destroy
  def destroy
    pending_delete!
  end
  
 protected
  def cloud
    environment.user.cloud
  end

  def attach_volume
    #TODO: handle errors
    cloud_volume.attach!(:instance_id => instance.cloud_id,
                         :device => image.storage_volume_device)
  end

  def create_in_cloud
    return if cloud_volume_is_available?
    #TODO: handle errors here
    @cloud_volume = cloud.create_storage_volume(:realm => environment.default_realm,
                                                :capacity => image.storage_volume_capacity)
    if @cloud_volume
      update_attribute(:volume_identifier, @cloud_volume.id)
      available!
    else
      fail!
    end
  end
  
  def destroy_cloud_volume
    result = true
    if cloud_volume_exists?
      if cloud_volume_is_available?
        cloud_volume.destroy!
        deleted!
      else
        result = false
      end
    end
    result
  end
  
end
