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

  belongs_to :artifact_version
  belongs_to :environment
  belongs_to :user

  has_many :deployment_instance_services, :dependent => :destroy
  has_many :instance_services, :through => :deployment_instance_services

  aasm_column :current_state
  aasm_initial_state :deployed
  aasm_state :deployed, :after_enter => :perform_deploy
  aasm_state :undeployed, :after_enter => :perform_undeploy

  aasm_event :undeploy do
    transitions :to => :undeployed, :from => :deployed
  end

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
    base_url.nil? ? nil : "#{environment.deployment_base_url}/#{simple_name}"
  end

  protected

  def perform_deploy
    environment.instance_services.running.for_service(service).each { |is| is.deploy(self) }
    audit_action :deployed
  end

  def perform_undeploy
    instance_services.each { |is| is.undeploy(self) }
    audit_action :undeployed
  end

end
