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

class InstanceService < ActiveRecord::Base
  include AASM
  include StateHelpers
  include HasMetadata

  has_events(:subject_name => :has_events_subject_name,
             :subject_parent => :instance,
             :subject_owner => lambda { |is| is.environment.user })
  
  belongs_to :instance
  belongs_to :service
  has_many :deployment_instance_services, :dependent => :destroy
  has_many :deployments, :through => :deployment_instance_services

  named_scope :for_service, lambda { |service| { :conditions => { :service_id => service.id } } }
  named_scope :not_pending, { :conditions => "instance_services.current_state <> 'pending'" }

  aasm_column :current_state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :configuring
  aasm_state :configure_failed
  aasm_state :verifying
  aasm_state :running, :after_enter => :running_entered

  aasm_event :configure do
    transitions :to => :configuring, :from => [:pending, :configuring, :verifying, :running]
  end

  aasm_event :verify do
    transitions :to => :verifying, :from => :configuring
  end

  aasm_event :fail do
    transitions :to => :configure_failed, :from => [:configuring, :verifying]
  end

  aasm_event :run do
    transitions :to => :running, :from => :verifying
  end

  before_destroy :remove_cluster_member_address
  
  def name
    service.name
  end

  def full_name
    service.full_name
  end

  def environment
    instance.environment
  end

  def instance_number
    instance.number
  end
  
  def agent_service
    @agent_service ||= AgentServices::Base.instance_for_service(service, instance.environment)
  end

  def agent_client
    instance.agent_client(service)
  end

  def configure_service
    if required_services_running?
      configure!
      verify! if agent_service.configure_instance_service(self)
    else
      logger.debug "InstanceService[#{id} #{name}]#configure_service - deferring configuration pending required services"
    end
    fail! if stuck_in_state_for_too_long?(5.minutes)
  end

  def verify_service
    run! if agent_service.verify_instance_service(self)
    fail! if stuck_in_state_for_too_long?(5.minutes)
  end

  def required_services_running?
    service.required_services.inject(true) do |accumulated_status, required_service|
      accumulated_status && environment.instance_services.for_service(required_service).all?(&:running?)
    end
  end

  def deploy(deployment)
    agent_service.deploy(self, deployment)
  end

  def artifact_metadata(deployment)
    agent_client.artifact(deployment.artifact_identifier)
  end
  
  def undeploy(deployment)
    agent_service.undeploy(self, deployment)
  end

  def url
    agent_service.url_for_instance_service(self)
  end

  def internal_hostname
    @internal_hostname ||= "#{name.downcase.gsub(/[^a-z0-9-]/, '-')}#{sprintf('%02d', instance_number)}.local"
  end

  def cluster_member_address_data
    [internal_hostname, instance.private_address]
  end

  def distribute_cluster_member_address
    environment.instances.running.each do |i|
      logger.debug "sending hostname #{internal_hostname} to #{i.name}"
      i.agent_client.create_cluster_member_address(*cluster_member_address_data)
    end
  end

  def remove_cluster_member_address
    #TODO: deal with errors
    environment.instances.running.each do |i|
      logger.debug "deleting hostname #{internal_hostname} from #{i.name}"
      i.agent_client.delete_cluster_member_address(internal_hostname)
    end
  end

  def has_events_subject_name
    "#{instance.name}: #{full_name} Service"
  end
    
  protected
  def running_entered
    handle_pending_deployments
    distribute_cluster_member_address
  end
  
  def handle_pending_deployments
    environment.deployments.deployed.select do |deployment|
      deployment.service == service
    end.each do |deployment|
      deploy(deployment)
    end
  end


end
