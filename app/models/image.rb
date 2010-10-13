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


class Image < ActiveRecord::Base
  has_many :platform_versions, :through => :platform_version_images
  has_many :instances
  has_many :image_services
  has_many :services, :through => :image_services

  def needs_storage_volume?
    !storage_volume_capacity.blank?
  end
  
  # See Platform.create_from_yaml_file
  def self.new_from_yaml(yaml)
    services = yaml.delete('services')
    image = Image.find_or_create_by_cloud_id(yaml)
    image.update_attributes!(yaml)
    image_services = image.services
    services && services.each do |service_name|
      service = Service.find_or_create_by_name(service_name)
      image.services << service unless image_services.include?(service)
    end
    image
  end
end
