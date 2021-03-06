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


class PlatformVersion < ActiveRecord::Base
  belongs_to :platform
  has_many :platform_version_images
  has_many :images, :through => :platform_version_images
  accepts_nested_attributes_for :images, :allow_destroy => true

  validates_presence_of :version_number

  def to_s
    version = version_number.blank? ? '' : " v#{version_number}"
    "#{platform}#{version}"
  end

  # See Platform.load_from_yaml_file
  def update_from_yaml(yaml)
    images = yaml.delete('images') || []
    update_attributes(yaml)
    self.images.clear
    images.each do |image_yaml|
      self.images << Image.new_from_yaml(image_yaml)
    end
  end
end
