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

class DeploymentInstanceService < ActiveRecord::Base
  include AASM
  include StuckState

  has_events(:subject_name => lambda { |dis| "#{dis.deployment.artifact_identifier} to #{instance_service.full_name}" },
             :subject_parent => :deployment,
             :subject_owner => lambda { |dis| dis.deployment.environment.user })
  
  belongs_to :deployment
  belongs_to :instance_service

  aasm_column :current_state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :deployed
  aasm_state :deploy_failed

  aasm_event :deployed do
    transitions :to => :deployed, :from => :pending
  end

  aasm_event :fail do
    transitions :to => :deploy_failed, :from => :pending
  end
  
  def confirm_deploy
    begin
      metadata = instance_service.artifact_metadata(deployment)
      deployed! if metadata and metadata['name']
    rescue AgentClient::RequestFailedError => ex
      Rails.logger.info "deploy confirmation failed for '#{deployment.artifact_identifier}': #{ex}"
      Rails.logger.info ex.backtrace.join("\n")
    end
    fail! if stuck_in_state_for_too_long?
  end
end
