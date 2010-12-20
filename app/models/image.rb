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
  has_many :cloud_images

  has_friendly_id :name, :use_slug => true, :allow_nil => true

  def needs_storage_volume?
    !storage_volume_capacity.blank?
  end

  # See Platform.load_from_yaml_file
  def self.new_from_yaml(yaml)
    services = yaml.delete('services')
    cloud_images = yaml.delete('cloud_images')
    image = Image.find_or_create_by_uid(yaml)
    image.update_attributes!(yaml)
    image.services.clear
    services && services.each do |service_name|
      service = Service.find_or_create_by_name(service_name)
      image.services << service
    end
    image.cloud_images.clear
    cloud_images && cloud_images.each do |cloud_image_yaml|
      image.cloud_images.find_or_create_by_cloud_id(cloud_image_yaml)
    end
    image
  end

  def cloud_id(hardware_profile, user)
    cloud = user.cloud
    architecture = cloud.architecture(hardware_profile)
    cloud_image = cloud_images.find(:first,
                                    :conditions => {
                                      :cloud => cloud.name,
                                      :region => cloud.region,
                                      :architecture => architecture})
    cloud_image.nil? ? nil : cloud_image.cloud_id
  end
end
