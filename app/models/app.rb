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


class App < ActiveRecord::Base
  belongs_to :user
  has_many :app_versions
  has_many :deployments, :through => :app_versions
  attr_protected :user
  validates_presence_of :name
  accepts_nested_attributes_for :app_versions

  def latest_version
    app_versions.first(:order => 'version_number desc')
  end

  def latest_version_number
    latest_version ? latest_version.version_number : nil
  end
end
