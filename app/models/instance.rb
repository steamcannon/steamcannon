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


class Instance < ActiveRecord::Base
  include AuditColumns
  include AASM
  include StateHelpers

  has_events(:subject_name => :name,
             :subject_owner => lambda { |i| i.environment.user },
             :subject_parent => :environment,
             :subject_metadata => :event_subject_metadata)

  has_friendly_id :name, :allow_nil => true, :use_slug => true

  belongs_to :environment
  belongs_to :image

  has_one :server_certificate, :as => :certifiable, :class_name => 'Certificate'
  has_one :storage_volume, :dependent => :nullify

  has_many :instance_services, :dependent => :destroy
  has_many :services, :through => :instance_services

  named_scope :not_stopped, :conditions => "instances.current_state <> 'stopped'"
  named_scope :not_stopping, :conditions => "instances.current_state <> 'stopping' AND instances.current_state <> 'terminating'"
  named_scope :not_failed, :conditions => "instances.current_state not in ('start_failed', 'configure_failed')"
  named_scope :in_environment, lambda { |env| { :conditions => { :environment_id => env.id } } }

  aasm_column :current_state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :starting, :enter => :start_instance
  aasm_state :attaching_volume
  aasm_state :configuring, :enter => :configure_instance
  aasm_state :verifying
  aasm_state :configure_failed, :enter => :state_failed
  aasm_state :running, :after_enter => :after_run_instance
  aasm_state :stopping, :enter => :stop_instance, :after_enter => :after_stop_instance
  aasm_state :terminating, :enter => :terminate_instance
  aasm_state :stopped, :after_enter => :after_stopped_instance
  aasm_state :start_failed, :enter => :state_failed
  aasm_state :unreachable


  aasm_event :start, :error => :error_raised do
    transitions :to => :starting, :from => :pending
  end

  aasm_event :attach_volume do
    transitions :to => :attaching_volume, :from => :starting, :guard => :has_storage_volume_and_is_running_in_cloud?
  end

  aasm_event :configure do
    transitions :to => :configuring, :from => [:starting, :attaching_volume], :guard => :running_in_cloud?
  end

  aasm_event :verify do
    transitions :to => :verifying, :from => :configuring
  end

  aasm_event :configure_failed do
    transitions :to => :configure_failed, :from => [:configuring, :verifying]
  end

  aasm_event :run do
    transitions :to => :running, :from => [:configuring, :verifying, :unreachable]
  end

  aasm_event :stop do
    transitions :to => :stopping, :from => [:pending, :starting, :configuring,
                                            :verifying, :running, :start_failed,
                                            :attaching_volume,
                                            :configure_failed, :unreachable]
  end

  aasm_event :terminate do
    transitions :to => :terminating, :from => :stopping
  end

  aasm_event :stopped do
    transitions :to => :stopped, :from => [:terminating, :unreachable], :guard => :stopped_in_cloud?
  end

  aasm_event :start_failed do
    transitions :to => :start_failed, :from => [:pending, :starting, :attaching_volume]
  end

  aasm_event :unreachable do
    transitions :to => :unreachable, :from => [:running, :pending, :starting, :configuring, :verifying,
                                               :attaching_volume,
                                               :configure_failed, :stopping, :terminating, :start_failed]
  end

  def can_stop?
    aasm_events_for_current_state.include?(:stop)
  end

  def self.deploy!(image, environment, number, hardware_profile)
    instance = Instance.new(:image_id => image.id,
                            :environment_id => environment.id,
                            :number => number,
                            :hardware_profile => hardware_profile)
    instance.audit_action :started
    instance.save!
    ModelTask.async(instance, :start!)
    instance
  end

  def name
    return "##{number}" if image.blank?
    "#{image.name} ##{number}"
  end

  def cloud
    cloud_profile.cloud
  end

  def cloud_instance
    @cloud_instance ||= cloud.instance(cloud_id)
  end

  def cloud_instance_url
    cloud_instance.blank? ? nil : cloud_instance.url
  end

  def agent_client(service_or_service_name = nil)
    service_or_service_name ||= services.first || :mock
    AgentClient.new(self, service_or_service_name.respond_to?(:name) ?
                    service_or_service_name.name : service_or_service_name)
  end

  def attach_volume
    storage_volume.attach!
    if storage_volume.attached?
      configure!
    elsif storage_volume.attach_failed? or
        stuck_in_state_for_too_long?(3.minutes)
      start_failed!
    end
  end

  def move_to_configure
    configure!
    start_failed! if stuck_in_state_for_too_long?(5.minutes)
  end

  def configure_agent
    generate_server_cert
    if agent_running?
      verify!
    elsif stuck_in_state_for_too_long?
      configure_failed!
    end
  end

  def reachable?
    # deltacloud returns the instance if it's available. We just want to return a boolean
    cloud.instance_available?(self.cloud_id) ? true : false
  end

  def terminated?
    cloud.instance_terminated?(self.cloud_id)
  end

  def verify_agent
    if agent_running?
      discover_services
      run!
    elsif stuck_in_state_for_too_long?
      configure_failed!
    end
  end

  def discover_services
    agent_client.agent_services.each do |service|
      service = Service.find_or_create_by_name(service)
      services << service
    end
    save
  end

  def agent_running?
    !agent_client.agent_status.nil?
  rescue AgentClient::RequestFailedError => ex
    false
  end

  def cloud_specific_hacks
    cloud_profile.cloud_specific_hacks
  end

  def user
    environment.user
  end

  def cloud_profile
    environment.cloud_profile
  end
  
  def unreachable_for_too_long?
    unreachable? && stuck_in_state_for_too_long?(48.hours)
  end

  def realm
    environment.realm
  end

  def deltacloud_state
    case current_state.to_s
    when 'stopped', 'start_failed'
      'stopped'
    when 'running', 'unreachable', 'stopping', 'terminating'
      'running'
    when 'pending', 'starting', 'attaching_volume', 'configuring', 'verifying'
      'pending'
    else
      'unknown'
    end
  end

  protected
  def start_instance
    image_cloud_id = image.cloud_id(hardware_profile, cloud_profile)
    raise RuntimeError.new("Cloud image not found for #{hardware_profile}") unless image_cloud_id
    cloud_instance = cloud.launch(image_cloud_id, instance_launch_options)
    update_addresses(cloud_instance, :cloud_id => cloud_instance.id)
  end

  def instance_launch_options
    {
      :hardware_profile => hardware_profile,
      :key_name => cloud_keyname,
      :user_data => instance_user_data,
      :realm_id => environment.realm
    }.merge(cloud_specific_hacks.launch_options(self))
  end

  def cloud_keyname
    environment.ssh_key_name
  end

  def instance_user_data
    { :steamcannon_ca_cert => Certificate.ca_certificate.certificate }.to_json
  end

  def running_in_cloud?
    update_addresses
    cloud_instance.state.downcase == 'running' and !public_address.blank?
  end

  def has_storage_volume_and_is_running_in_cloud?
    storage_volume and running_in_cloud?
  end

  def configure_instance
    update_addresses
  end

  def after_run_instance
    environment.run!
    update_cluster_member_addresses
  end

  def stop_instance
    audit_action :stopped
    save!
  end

  def after_stop_instance
    ModelTask.async(self, :terminate!)
  end

  def terminate_instance
    cloud.terminate(cloud_id) unless cloud_id.nil? || !cloud.instance_available?(cloud_id)
  end

  def stopped_in_cloud?
    cloud_instance.nil? or
      ['terminated', 'stopped'].include?(cloud_instance.state.downcase)
  end

  def after_stopped_instance
    environment.stopped! if environment.stopping?
    environment.instance_state_change(self)
    destroy
  end

  def error_raised(error)
    Rails.logger.error "Instance#error_raised ==========================="
    logger.error error.try(:with_trace)
    Rails.logger.error "================================================="
    @last_error = error
    start_failed!
  end

  def state_failed
    environment.failed!
  end

  def generate_server_cert
    unless public_address.blank? or server_certificate
      self.server_certificate = Certificate.generate_server_certificate(self)
    end
  end

  def update_addresses(cloud_instance = self.cloud_instance,
                       additional_fields = {})
    update_attributes({
                        :public_address => cloud_instance.public_addresses.first,
                        :private_address => cloud_instance.private_addresses.first
                      }.merge(additional_fields))
  end

  def update_cluster_member_addresses
    environment.instance_services.running.each &:distribute_cluster_member_address
  end

  def event_subject_metadata
    {
      :cloud_name => cloud_profile.cloud_name,
      :cloud_provider => cloud_profile.provider_name,
      :cloud_instance_id => cloud_id,
      :cloud_image_id => image.cloud_id(hardware_profile, cloud_profile),
      :cloud_hardware_profile => hardware_profile,
      :started_by => started_by,
      :stopped_by => stopped_by
    }
  end
end
