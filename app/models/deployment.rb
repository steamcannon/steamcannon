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

  named_scope :active, :conditions => "current_state = 'deploying' OR current_state = 'deployed'"
  named_scope :inactive, :conditions => "current_state = 'undeployed' OR current_state = 'deploy_failed'"

  before_create :record_deploy
  after_create :notify_environment_of_deploy
  
  aasm_column :current_state
  aasm_initial_state :deploying
  aasm_state :deploying
  aasm_state :deploy_failed
  aasm_state :deployed, :enter => :record_deploy
  aasm_state :undeployed, :enter => :record_undeploy

  aasm_event :fail do
    transitions :to => :deploy_failed, :from => :deploying
  end

  aasm_event :mark_as_deployed do
    transitions :to => :deployed, :from => :deploying
  end

  aasm_event :mark_as_undeployed do
    transitions :to => :undeployed, :from => [:deployed, :deploying]
  end

  def artifact
    artifact_version.artifact
  end

  def service
    artifact.service
  end


=begin
  def deploy
    return unless environment.ready_for_deployments?

    instances_for_deploy.each do |instance|
      begin
        response = instance.agent_client(service).deploy_artifact(artifact_version)
        if response.respond_to?(:[]) and response['artifact_id']
          self.agent_artifact_identifier = response['artifact_id']
        else
          logger.info "deploying artifact failed. response from agent: #{response}"
          fail!
        end

      rescue AgentClient::RequestFailedError => ex
        #TODO: store the failure reason?
        logger.info "deploying artifact failed: #{ex}"
        logger.info ex.backtrace.join("\n")
        fail!
      end
    end
    mark_as_deployed!
  end

  def undeploy
    return unless deployed?

    instances_for_deploy.each do |instance|
      begin
        instance.agent_client(service).undeploy_artifact(agent_artifact_identifier)
      rescue AgentClient::RequestFailedError => ex
        #TODO: store the failure reason?
        logger.info "undeploying artifact failed: #{ex}"
        logger.info ex.backtrace.join("\n")
      end
    end
    mark_as_undeployed!
  end
=end


  private
  
  def notify_environment_of_deploy
    environment.trigger_deployments(self)
  end
  
#   def instances_for_deploy
#     service.instances.running.in_environment(environment)
#   end

  def record_deploy
    audit_action :deployed
  end

  def record_undeploy
    audit_action :undeployed
  end
end
