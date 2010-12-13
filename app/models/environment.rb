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
  include HasMetadata
  include StateHelpers

  has_events :subject_name => :name, :subject_owner => :user

  has_many :deployments, :dependent => :destroy
  has_many :environment_images, :dependent => :destroy
  has_many :images, :through => :environment_images
  has_many :storage_volumes, :through => :environment_images
  has_many :instances
  has_many :instance_services, :through => :instances

  belongs_to :platform_version
  belongs_to :user
  belongs_to :cloud_profile
  
  attr_protected :user_id

  accepts_nested_attributes_for :environment_images

  validates_presence_of :name, :user
  validates_uniqueness_of :name, :scope => :user_id

  default_scope :order => 'name ASC'

  aasm_column :current_state
  aasm_initial_state :stopped
  aasm_state :starting, :enter => :start_environment
  aasm_state :running, :after_enter => :move_instance_services_to_configuring
  aasm_state :stopping, :after_enter => :stop_environment
  aasm_state :stopped
  aasm_state :start_failed

  aasm_event :start do
    transitions :to => :starting, :from => :stopped
  end

  aasm_event :run do
    transitions :to => :running, :from => [:starting, :running], :guard => :running_all_instances?
  end

  aasm_event :stop do
    transitions :to => :stopping, :from => [:running, :starting, :start_failed, :starting]
  end

  aasm_event :stopped do
    transitions :to => :stopped, :from => :stopping, :guard => :stopped_all_instances?
  end

  aasm_event :failed do
    transitions :to => :start_failed, :from => [:starting, :start_failed]
  end

  before_update :remove_images_from_prior_platform_version

  def cloud
    user.cloud
  end

  def region
    user.cloud.region
  end

  def platform
    platform_version.platform
  end

  def start_instance(image_id)
    return false unless running?
    environment_image = environment_images.detect {|i|i.image.friendly_id == image_id}
    return false unless environment_image && environment_image.can_start_more?
    environment_image.start_another!
  end

  def can_start?
    aasm_events_for_current_state.include?(:start)
  end

  def can_stop?
    aasm_events_for_current_state.include?(:stop)
  end

  def deployment_base_url
    first_service_base_url('mod_cluster') or first_service_base_url('jboss_as')
  end

  def clone!(attributes_to_override = { })
    new_attributes = {
      :name => "#{name} (copy)",
      :current_state => 'stopped'
    }
    super(attributes_to_override.merge(new_attributes)).tap do |copy|
      environment_images.each { |ei| ei.clone!(:environment_id => copy.id) }
    end
  end

  def artifacts
    deployments.deployed.collect(&:artifact)
  end

  def instance_state_change(instance)
    self.stop! if instance.stopped? && instances.include?(instance) &&
      instances.all?{|i|i.stopped?} && !self.stopping? && !self.stopped?
  end

  def instance_states
    instances.inject({}) do |accum, i|
      accum[i.current_state] ||= []
      accum[i.current_state] << i
      accum
    end
  end

  def usage_data(cloud_helper)
    @usage_data ||= EnvironmentUsage.new(self, cloud_helper)
  end


  protected

  def start_environment
    log_event(:operation => :start_environment)

    update_attribute(:realm, user.default_realm)

    # destroy any instances from prior runs that may be hanging
    # around. Instances self destroy on stop, but this catches any
    # that didn't make it to the stopped state.
    instances.each(&:destroy)

    environment_images.each do |env_image|
      env_image.num_instances.times do |i|
        env_image.start!(i+1)
      end
    end
  end

  def stop_environment
    deployments.deployed.each(&:undeploy!)
    storage_volumes.each(&:detach!)
    instances.not_stopped.not_stopping.each(&:stop!)
    storage_volumes.each(&:destroy) unless preserve_storage_volumes?
    # try to move to stopped here - state won't change if there are still
    # running instances, but this catches the case where all instances
    # are stopped individually [STEAM-153]
    stopped!
  end

  def running_all_instances?
    instances.not_stopped.all?(&:running?)
  end

  def stopped_all_instances?
    instances.not_stopped.count == 0
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

  def first_service_base_url(service_name)
    service = Service.find_by_name(service_name)
    services = instance_services.for_service(service)
    unless services.empty?
      instance_service = services.first
      instance_service.agent_service.url_for_instance(instance_service.instance)
    end
  end
end

