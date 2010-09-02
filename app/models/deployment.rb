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

  belongs_to :app_version
  belongs_to :environment
  belongs_to :user

  named_scope :active, :conditions => 'undeployed_at is null'
  named_scope :inactive, :conditions => 'undeployed_at is not null'

  before_create :record_deploy

  def app
    app_version.app
  end

  def undeploy!
    audit_action :undeployed
    save!
  end

  def undeployed?
    !undeployed_at.nil?
  end

  private
  def record_deploy
    audit_action :deployed
  end
end
