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


class ArtifactVersion < ActiveRecord::Base

  TYPES = [
    :ear, :war, :jar, :rails, :rack, :datasource, :other
  ]

  TYPE_DESCRIPTIONS = {
    :ear => 'Java Enterprise Application Archive',
    :war => 'Java Web Application Archive',
    :jar => 'Java Archive',
    :rails => 'Rails Archive',
    :rack => 'Rack Archive',
    :datasource => 'Datasource',
    :other => 'Other',
  }

  belongs_to :artifact
  has_many :deployments
  has_attached_file(:archive,
                    :storage => 'Cloud::Storage',
                    :path => ':id/:filename')
  validates_attachment_presence :archive
  attr_protected :version_number, :artifact
  before_create :assign_version_number

  def assign_version_number
    self.version_number = (self.artifact.latest_version_number || 0) + 1
  end

  def to_s
    "#{artifact.name} version #{version_number}"
  end

  def supports_pull_deployment?
    archive && !archive.public_url.blank?
  end

  def pull_deployment_url
    archive.public_url
  end

  def deployment_file
    archive.to_file
  end

  def type_key
    case ( archive_file_name )
      when /\.ear$/
        :ear
      when /\.war$/
        :war
      when /\.jar$/
        :jar
      when /\.rails$/
        :rails
      when /\.rack$/
        :rack
      when /\-ds.xml$/
        :datasource
      else
        :other
    end
  end

  def type_description
    TYPE_DESCRIPTIONS[type_key]
  end

  def application?
    [ :ear, :war, :rails, :rack ].include?(type_key)
  end

end
