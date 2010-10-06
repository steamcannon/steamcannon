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
  has_many :artifacts
  has_many :environments
  has_many :deployments
  has_many :artifact_versions, :through => :artifacts

  before_save :encrypt_cloud_password
  validate :validate_cloud_credentials
  validate :validate_ssh_key_name

  acts_as_authentic do |c|
  end

  named_scope :visible_to_user, lambda { |user|
    { :conditions => user.superuser? ? { } : { :id => user.id } }
  }

  attr_protected :superuser

  attr_accessor_with_default :cloud_password_dirty, false
  attr_accessor_with_default( :cloud_password ) do
    self.crypted_cloud_password.blank? ? @cloud_password : Certificate.decrypt(self.crypted_cloud_password)
  end

  def obfuscated_cloud_password
    obfuscated = cloud_password.dup
    if obfuscated.length < 6
      obfuscated = '******'
    else
      obfuscated[0..-5] = '*' * (cloud_password.length-4)
    end
    obfuscated
  end

  def cloud_password=(pw)
    @cloud_password_dirty = true
    @cloud_password = pw
  end

  def cloud
    Cloud::Deltacloud.new(cloud_username, cloud_password)
  end

  def profile_complete?
    self.superuser? || (!self.cloud_username.blank? && !self.crypted_cloud_password.blank?)
  end

  def encrypt_cloud_password
    self.crypted_cloud_password = Certificate.encrypt(@cloud_password) if (@cloud_password_dirty || (new_record? && !@cloud_password.blank?))
  end

  def validate_cloud_credentials
    if cloud_username_changed? or @cloud_password_dirty
      message = "Cloud credentials are invalid"
      errors.add_to_base(message) unless cloud.valid_credentials?
    end
  end

  def validate_ssh_key_name
    if ssh_key_name_changed? and !ssh_key_name.blank?
      message = "SSH key name is invalid"
      errors.add_to_base(message) unless cloud.valid_key_name?(ssh_key_name)
    end
  end

end
