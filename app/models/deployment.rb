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
  
  def undeploy
    instance_services.each { |is| is.undeploy(self) }
  end

  private
  
  def notify_environment_of_deploy
    environment.trigger_deployments(self)
  end
  
  def record_deploy
    audit_action :deployed
  end

  def record_undeploy
    audit_action :undeployed
  end
end
