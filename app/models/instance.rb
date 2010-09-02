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

  before_create :generate_certs

  named_scope :active, :conditions => "current_state <> 'stopped'"
  named_scope :inactive, :conditions => "current_state = 'stopped'"

  aasm_column :current_state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :starting, :enter => :start_instance
  aasm_state :running, :enter => :run_instance, :after_enter => :after_run_instance
  aasm_state :stopping, :enter => :stop_instance, :after_enter => :after_stop_instance
  aasm_state :terminating, :enter => :terminate_instance
  aasm_state :stopped, :after_enter => :after_stopped_instance
  aasm_state :start_failed, :enter => :state_failed

  aasm_event :start, :error => :error_raised do
    transitions :to => :starting, :from => :pending
  end

  aasm_event :run do
    transitions :to => :running, :from => :starting, :guard => :running_in_cloud?
  end

  aasm_event :stop do
    transitions :to => :stopping, :from => [:running, :starting, :pending, :start_failed]
  end

  aasm_event :terminate do
    transitions :to => :terminating, :from => :stopping
  end

  aasm_event :stopped do
    transitions :to => :stopped, :from => :terminating, :guard => :stopped_in_cloud?
  end

  aasm_event :failed do
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

  protected

  def start_instance
    cloud_instance = cloud.launch(image.cloud_id,
                                  hardware_profile,
                                  instance_launch_options)
    self.update_attributes(:cloud_id => cloud_instance.id,
                           :public_dns => cloud_instance.public_addresses.first)
  end

  def instance_launch_options
    { :user_data => instance_user_data }
  end

  def instance_user_data
    user_data = { }
    user_data[:steamcannon_client_cert] = Certificate.client_certificate.certificate if APP_CONFIG[:use_ssl_with_agents]
    user_data.to_json
  end
  
  def running_in_cloud?
    cloud_instance.state.downcase == 'running'
  end

  def run_instance
    self.update_attributes(:public_dns => cloud_instance.public_addresses.first)
  end

  def after_run_instance
    environment.run!
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
    failed!
  end

  def state_failed
    environment.failed!
  end

  def generate_certs
    #TODO: point this at Certificate
  end

end
