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


class Deployment < ActiveRecord::Base
  include AuditColumns
  include AASM

  has_events :subject_name => :artifact_identifier, :subject_parent => :environment, :subject_owner => :user
  belongs_to :artifact_version
  belongs_to :environment
  belongs_to :user

  has_many :deployment_instance_services, :dependent => :destroy
  has_many :instance_services, :through => :deployment_instance_services

  validates_each :environment_id, :on => :create do |record, attr, value|
    record.send(:validate_artifact_unique_in_environment)
  end

  aasm_column :current_state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :deployed, :after_enter => :perform_deploy_async
  aasm_state :undeployed, :after_enter => :perform_undeploy_async

  aasm_event :deploy do
    transitions :to => :deployed, :from => :pending
  end

  aasm_event :undeploy do
    transitions :to => :undeployed, :from => :deployed
  end

  after_create :deploy!

  def artifact
    artifact_version.artifact
  end

  def service
    artifact.service
  end

  def artifact_identifier
    !agent_artifact_identifier.blank? ? agent_artifact_identifier : artifact_version.archive_file_name
  end

  def simple_name
    artifact_identifier.gsub(/^(.+)\.(war|ear|rails|rack)$/, '\1')
  end

  def url
    base_url = environment.deployment_base_url
    if !base_url.nil? and artifact_version.application?
      "#{environment.deployment_base_url}/#{simple_name}"
    else
      nil
    end
  end

  def is_deployed?
    instance_services.exists?
  end

  protected

  def validate_artifact_unique_in_environment
    artifact = artifact_version.artifact
    if environment.artifacts.include?(artifact)
      errors.add :environment_id, "'#{environment.name}' already has a version of '#{artifact.name}' deployed to it."
    end
  end

  def perform_deploy_async
    audit_action :deployed
    ModelTask.async(self, :perform_deploy)
  end

  def perform_undeploy_async
    audit_action :undeployed
    ModelTask.async(self, :perform_undeploy)
  end

  def perform_deploy
    if artifact_version.uploaded?
      environment.instance_services.running.for_service(service).each { |is| is.deploy(self) }
    elsif artifact_version.upload_failed?
      # Do nothing, which for now leaves this in Pending Deployment forever
      # We'll want to add some kind of deploy failed state so if someone tries
      # to deploy an artifact that fails to upload we can display a message
    else
      sleep(5)
      ModelTask.async(self, :perform_deploy)
    end
  end

  def perform_undeploy
    instance_services.each { |is| is.undeploy(self) }
  end
end
