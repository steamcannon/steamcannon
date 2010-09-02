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
  has_many :apps
  has_many :environments
  has_many :deployments
  has_many :app_versions, :through => :apps

  acts_as_authentic do |c|
  end

  named_scope :visible_to_user, lambda { |user|
    { :conditions => user.superuser? ? { } : { :id => user.id } }
  }

  attr_protected :superuser
  
  def cloud
    Cloud::Deltacloud.new(cloud_username, cloud_password)
  end
end
