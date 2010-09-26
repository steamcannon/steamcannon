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

  belongs_to :environment
  belongs_to :image

  has_one :server_certificate, :as => :certifiable, :class_name => 'Certificate'
  has_many :instance_services, :dependent => :destroy
  has_many :services, :through => :instance_services
  has_many :instance_deployments
  has_many :deployments, :through => :instance_deployments

  before_save :set_state_change_timestamp

  named_scope :active, :conditions => "current_state <> 'stopped'"
  named_scope :inactive, :conditions => "current_state = 'stopped'"
  named_scope :in_environment, lambda { |env| { :conditions => { :environment_id => env.id } } }

  aasm_column :current_state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :starting, :enter => :start_instance
  aasm_state :configuring, :enter => :configure_instance
  aasm_state :verifying
  aasm_state :configuring_services
  aasm_state :verifying_services
  aasm_state :configure_failed, :enter => :state_failed
  aasm_state :running, :after_enter => :after_run_instance
  aasm_state :stopping, :enter => :stop_instance, :after_enter => :after_stop_instance
  aasm_state :terminating, :enter => :terminate_instance
  aasm_state :stopped, :after_enter => :after_stopped_instance
  aasm_state :start_failed, :enter => :state_failed


  aasm_event :start, :error => :error_raised do
    transitions :to => :starting, :from => :pending
  end

  aasm_event :configure do
    transitions :to => :configuring, :from => :starting, :guard => :running_in_cloud?
  end

  aasm_event :verify do
    transitions :to => :verifying, :from => :configuring
  end

  aasm_event :configure_services do
    transitions :to => :configuring_services, :from => :verifying
  end

  aasm_event :verify_services do
    transitions :to => :verifying_services, :from => :configuring_services
  end

  aasm_event :configure_failed do
    transitions :to => :configure_failed, :from => [
                                                    :configuring,
                                                    :verifying,
                                                    :configuring_services,
                                                    :verifying_services
                                                   ]
  end

  aasm_event :run do
    transitions :to => :running, :from => [:configuring, :verifying, :verifying_services]
  end

  aasm_event :stop do
    transitions :to => :stopping, :from => [:pending, :starting, :configuring,
                                            :verifying, :running, :start_failed,
                                            :configure_failed]
  end

  aasm_event :terminate do
    transitions :to => :terminating, :from => :stopping
  end

  aasm_event :stopped do
    transitions :to => :stopped, :from => :terminating, :guard => :stopped_in_cloud?
  end

  aasm_event :start_failed do
    transitions :to => :start_failed, :from => :pending
  end


  def self.deploy!(image, environment, name, hardware_profile)
    instance = Instance.new(:image_id => image.id,
                            :environment_id => environment.id,
                            :name => name,
                            :hardware_profile => hardware_profile)
    instance.audit_action :started
    instance.save!
    InstanceTask.async(:launch_instance, :instance_id => instance.id)
    instance
  end

  def cloud
    environment.user.cloud
  end

  def cloud_instance
    @cloud_instance ||= cloud.instance(cloud_id)
  end

  def agent_client(service_or_service_name = nil)
    service_or_service_name ||= services.first || :mock
    AgentClient.new(self, service_or_service_name.respond_to?(:name) ?
                    service_or_service_name.name : service_or_service_name)
  end

  def configure_agent
    generate_server_cert
    if agent_running?
      verify!
    elsif stuck_in_state_for_too_long?
      configure_failed!
    end
  end

  def verify_agent
    if agent_running?
      discover_services
      configure_services!
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

  def configure_services
    instance_services.each(&:configure)
    verify_services!
  rescue AgentClient::RequestFailedError => ex
    logger.error ex.inspect
    logger.error ex.backtrace
    configure_failed! if stuck_in_state_for_too_long?
  end

  def verify_services
    begin
      run! if instance_services.all?(&:verify)
    rescue AgentClient::RequestFailedError => ex
      logger.error ex.inspect
      logger.error ex.backtrace
    end
    configure_failed! if stuck_in_state_for_too_long?
  end

  def agent_running?
    !agent_client.agent_status.nil?
  rescue AgentClient::RequestFailedError => ex
    false
  end

  def cloud_specific_hacks
    @cloud_hacks ||= "Cloud::#{cloud.name.camelize}".constantize.new(self)
  end

  protected
  def stuck_in_state_for_too_long?
    state_change_timestamp <= Time.now - 120.seconds
  end
  
  def start_instance
    cloud_instance = cloud.launch(image.cloud_id,
                                  instance_launch_options)
    self.update_attributes(:cloud_id => cloud_instance.id,
                           :public_dns => cloud_instance.public_addresses.first)
  end

  def instance_launch_options
    {
      # FIXME: check this, according to docs it should be hwp_id
      # (http://localhost:8080/deltacloud/api/docs/instances/create)
      :hardware_profile => hardware_profile,
      :keyname => cloud_keyname,
      :user_data => instance_user_data
    }.merge(cloud_specific_hacks.launch_options)
  end
  
  def cloud_keyname
    environment.user.ssh_key_name
  end

  def instance_user_data
    user_data = { :steamcannon_ca_cert => Certificate.ca_certificate.certificate }
    Base64.encode64(user_data.to_json)
  end

  def running_in_cloud?
    update_attributes(:public_dns => cloud_instance.public_addresses.first)
    cloud_instance.state.downcase == 'running' and !public_dns.blank?
  end

  def configure_instance
    update_attributes(:public_dns => cloud_instance.public_addresses.first)
  end

  def after_run_instance
    environment.run!
    environment.trigger_deployments(self)
  end

  def stop_instance
    audit_action :stopped
    save!
  end

  def after_stop_instance
    InstanceTask.async(:stop_instance, :instance_id => self.id)
  end

  def terminate_instance
    cloud.terminate(cloud_id) unless cloud_id.nil?
  end

  def stopped_in_cloud?
    cloud_instance.nil? or
      ['terminated', 'stopped'].include?(cloud_instance.state.downcase)
  end

  def after_stopped_instance
    environment.stopped!
  end

  def error_raised(error)
    logger.error error.inspect
    logger.error error.backtrace
    start_failed!
  end

  def state_failed
    environment.failed!
  end

  def generate_server_cert
    unless public_dns.blank? or server_certificate
      self.server_certificate = Certificate.generate_server_certificate(self)
    end
  end

  def set_state_change_timestamp
    self.state_change_timestamp = Time.now if current_state_changed?
  end
end
