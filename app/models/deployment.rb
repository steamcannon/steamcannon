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

  named_scope :active, :conditions => 'undeployed_at is null'
  named_scope :inactive, :conditions => 'undeployed_at is not null'

  before_create :record_deploy

  aasm_column :current_state
  aasm_initial_state :deploying
  aasm_state :deploying
  aasm_state :deploy_failed
  aasm_state :deployed, :enter => :record_deploy
  aasm_state :undeployed, :enter => :record_undeploy

  aasm_event :fail do
    transitions :to => :deploy_failed, :from => :deploying
  end

  aasm_event :deployed do
    transitions :to => :deployed, :from => :deploying
  end

  aasm_event :undeploy do
    transitions :to => :undeployed, :from => :deployed
  end

  def artifact
    artifact_version.artifact
  end

  def service
    artifact.service
  end

  def deploy_artifact
    return unless environment.ready_for_deployments?
    
    instances_for_deploy.each do |instance|
      begin
        response = instance.agent_client(service).deploy_artifact(artifact_version)
        if response.respond_to?(:[]) and response[:artifact_id]
          self.agent_artifact_identifier = response[:artifact_id]
          deployed!
        else
          logger.info "deploying artifact failed. response from agent: #{response}"
          fail!
        end

      rescue AgentClient::RequestFailedError => ex
        #TODO: store the failure reason?
        logger.info "deploying artifact failed: #{ex}", ex.backtrace
        fail!
      end
    end
  end

  private

  def instances_for_deploy
    chain = service.instances.running.in_environment(environment)
  end

  def record_deploy
    audit_action :deployed
  end

  def record_undeploy
    audit_action :undeployed
  end
end
