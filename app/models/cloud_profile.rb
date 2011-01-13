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

class CloudProfile < ActiveRecord::Base
  include HasMetadata

  belongs_to :organization

  has_many :environments
  has_many :artifacts
  
  before_save :encrypt_password

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :organization_id
  
  validate :validate_cloud_credentials

  attr_accessor_with_default :password_dirty, false
  attr_accessor_with_default( :password ) do
    (@password_dirty or self.crypted_password.blank?) ? @password : Certificate.decrypt(self.crypted_password)
  end

  def obfuscated_password
    obfuscated = password ? password.dup : ''
    if obfuscated.length < 6
      obfuscated = '******'
    else
      obfuscated[0..-5] = '*' * (password.length-4)
    end
    obfuscated
  end

  def password=(pw)
    @password_dirty = true
    @password = pw
  end

  def name_with_details
    "#{name} (#{cloud_name}:#{provider_name})"
  end

  def cloud
    @cloud ||= Cloud::Deltacloud.new(username, password, cloud_name, provider_name)
  end

  def cloud_specifics
    @cloud_hacks ||= Cloud::Specifics::Base.cloud_specifics(cloud_name, self)
  end 

  protected
  def encrypt_password
    if @password_dirty || (new_record? && !@password.blank?)
      self.crypted_password = Certificate.encrypt(@password)
    end
  end

  def validate_cloud_credentials
    if username_changed? or @password_dirty
      message = "Cloud credentials are invalid"
      begin
        message = nil if cloud.valid_credentials?
      rescue Exception => ex
        #ignore
      end
      errors.add_to_base(message) if message
    end
  end
end
