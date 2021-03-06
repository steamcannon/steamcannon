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

class Organization < ActiveRecord::Base
  has_many :users
  has_many :account_requests
  has_many :cloud_profiles
  has_many :environments, :through => :users
  has_many :artifacts, :through => :users
  
  def to_s
    name
  end

  def has_cloud_profiles?
    case cloud_profiles.count
    when 0
      false
    when 1
      !cloud_profiles.first.new_record?
    else
      true
    end
  end
end
