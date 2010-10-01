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


class Environment < ActiveRecord::Base
  include AASM

  has_many :deployments
  has_many :environment_images, :dependent => :destroy
  has_many :images, :through => :environment_images
  has_many :instances
  has_many :instance_services, :through => :instances
  
  belongs_to :platform_version
  belongs_to :user
  attr_protected :user_id
  accepts_nested_attributes_for :environment_images
  validates_presence_of :name, :user

  aasm_column :current_state
  aasm_initial_state :stopped
  aasm_state :starting, :enter => :start_environment
  aasm_state :running, :after_enter => :move_instance_services_to_configuring
  aasm_state :stopping, :enter => :stop_environment
  aasm_state :stopped
  aasm_state :start_failed

  aasm_event :start do
    transitions :to => :starting, :from => :stopped
  end

  aasm_event :run do
    transitions :to => :running, :from => :starting, :guard => :running_all_instances?
  end

  aasm_event :stop do
    transitions :to => :stopping, :from => [:running, :start_failed, :starting]
  end

  aasm_event :stopped do
    transitions :to => :stopped, :from => :stopping, :guard => :stopped_all_instances?
  end

  aasm_event :failed do
    transitions :to => :start_failed, :from => [:starting, :start_failed]
  end

  before_update :remove_images_from_prior_platform_version

  def platform
    platform_version.platform
  end

  def can_start?
    aasm_events_for_current_state.include?(:start)
  end

  def can_stop?
    aasm_events_for_current_state.include?(:stop)
  end

  protected

  def start_environment
    environment_images.each do |env_image|
      env_image.num_instances.times do |i|
        env_image.start!(i+1)
      end
    end
  end

  def stop_environment
    deployments.deployed.each(&:undeploy!)
    instances.active.each(&:stop!)
  end

  def running_all_instances?
    instances.active.all?(&:running?)
  end

  def stopped_all_instances?
    instances.active.count == 0
  end

  def remove_images_from_prior_platform_version
    if platform_version_id_changed?
      # remove any images that aren't part of the new platform version
      new_images = platform_version.images.all
      environment_images.each do |env_image|
        env_image.destroy unless new_images.include?(env_image.image)
      end
    end
  end

  def move_instance_services_to_configuring
    instance_services.pending.each(&:configure!)
  end
end
