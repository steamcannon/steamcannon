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
  aasm_state :running, :enter => :run_instance
  aasm_state :stopping, :enter => :stop_instance
  aasm_state :terminating, :enter => :terminate_instance
  aasm_state :stopped

  aasm_event :start do
    transitions :to => :starting, :from => :pending
  end

  aasm_event :run do
    transitions :to => :running, :from => :starting, :guard => :running_in_cloud?
  end

  aasm_event :stop do
    transitions :to => :stopping, :from => [:running, :starting, :pending]
  end

  aasm_event :terminate do
    transitions :to => :terminating, :from => :stopping
  end

  aasm_event :stopped do
    transitions :to => :stopped, :from => :terminating, :guard => :stopped_in_cloud?
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
                                  hardware_profile)
    self.update_attributes(:cloud_id => cloud_instance.id,
                           :public_dns => cloud_instance.public_addresses.first)
  end

  def running_in_cloud?
    cloud_instance.state.downcase == 'running'
  end

  def run_instance
    self.public_dns = cloud_instance.public_addresses.first
  end

  def stop_instance
    audit_action :stopped
    save!
    InstanceTask.async(:stop_instance, :instance_id => self.id)
  end

  def terminate_instance
    cloud.terminate(cloud_id)
  end

  def stopped_in_cloud?
    cloud_instance.nil? or cloud_instance.state.downcase == 'terminated'
  end

  def generate_certs
    self.server_key, self.server_cert = AgentCert.generate("CT Agent", 'serverAuth')
    self.client_key, self.client_cert = AgentCert.generate("CT", 'clientAuth')
  end

end
