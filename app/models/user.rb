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


class User < ActiveRecord::Base
  belongs_to :organization
  has_many :artifacts
  has_many :environments
  has_many :deployments
  has_many :artifact_versions, :through => :artifacts
  has_many :instances, :through => :environments
  has_many :event_subjects, :as => :owner

  accepts_nested_attributes_for :organization
  validate :validate_ssh_key_name
  after_create :ensure_organization

  acts_as_authentic do |c|
  end

  named_scope :visible_to_user, lambda { |user|
    conditions = case
                 when user.superuser?
                   {}
                 when user.organization_admin?
                   { :organization_id => user.organization_id }
                 else
                   { :id => user.id }
                 end
    { :conditions => conditions }
  }

  attr_protected :superuser

  def cloud
    organization.cloud
  end

  def cloud_username
    organization.cloud_username
  end

  def cloud_password
    organization.cloud_password
  end

  def profile_complete?
    self.superuser? || (!self.cloud_username.blank? &&
                        !self.cloud_password.blank? &&
                        !self.default_realm.blank?)
  end

  def validate_ssh_key_name
    if ssh_key_name_changed? and !ssh_key_name.blank?
      message = "SSH key name is invalid"
      errors.add_to_base(message) unless cloud.valid_key_name?(ssh_key_name)
    end
  end

  def cloud_specific_hacks
    @cloud_hacks ||= "Cloud::#{cloud.name.camelize}".constantize.new(self)
  end

  def environment_bucket_name
    cloud_specific_hacks.unique_bucket_name("SteamCannonEnvironments_")
  end

  def artifact_bucket_name
    cloud_specific_hacks.unique_bucket_name("SteamCannonArtifacts_")
  end

  def send_password_reset_instructions!(host)
    reset_perishable_token!
    from = APP_CONFIG[:default_reply_to_address] || self.email
    PasswordResetMailer.deliver_password_reset_instructions(host, self, from)
  end

  def organization_admin?
    true
  end

  def ensure_organization
    if organization.nil?
      org = Organization.create!(:name => email)
      org.users << self
      org.save!
    end
  end
end
