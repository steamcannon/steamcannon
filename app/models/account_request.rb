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

class AccountRequest < ActiveRecord::Base
  include AASM
  
  validates_presence_of :email

  before_create :create_token
  
  aasm_column :current_state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :invited
  aasm_state :ignored
  aasm_state :accepted

  aasm_event :invite do
    transitions :to => :invited, :from => [:pending, :invited]
  end

  aasm_event :ignore do
    transitions :to => :ignored, :from => :pending
  end
  
  aasm_event :accept do
    transitions :to => :accepted, :from => :invited
  end
  
  def send_invitation(host, from)
    ModelTask.async(self, :_send_invitation, host, from)
    invite!
  end

  def send_request_notification(host, to)
    ModelTask.async(self, :_send_request_notification, host, to)
  end

  protected
  def create_token
    self.token = ActiveSupport::SecureRandom::hex(8) 
  end

  def _send_invitation(host, from)
    AccountRequestMailer.deliver_invitation(host, from, email, token)
  end
  
  def _send_request_notification(host, to)
    AccountRequestMailer.deliver_request_notification(host, self, to)
  end

end
