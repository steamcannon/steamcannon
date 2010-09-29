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
  
  belongs_to :instance
  belongs_to :service

  aasm_column :current_state

  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :configured
  aasm_state :verified

  aasm_event :configured do
    transitions :to => :configured, :from => :pending
  end
  
  aasm_event :verified do
    transitions :to => :verified, :from => :configured
  end
  
  def name
    service.name
  end

  def agent_service
    @agent_service ||= AgentServices::Base.instance_for_service(service, instance.environment)
  end
  
  def configure
    configured! if agent_service.configure_instance(instance)
  end

  def verify
    verified! if agent_service.verify_instance(instance)
  end

end
