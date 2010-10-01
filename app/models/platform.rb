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


class Platform < ActiveRecord::Base
  has_many :platform_versions

  accepts_nested_attributes_for :platform_versions, :allow_destroy => true

  def to_s
    name
  end

  # Create new Platform(s) from the given YAML file
  #
  # This is only meant to be used for creating new platforms, not for
  # updating existing ones. An example of the expected YAML file syntax:
  #
  # ---
  # platforms:
  #   - name: Test Platform
  #     platform_versions:
  #       - version_number: 123
  #         images:
  #           - name: Test Image 123
  #             cloud_id: ami_123
  #             role: frontend
  #           - name: Test Image 234
  #             cloud_id: ami_234
  #             services:
  #               - jboss_as
  #       - version_number: 234
  #         images:
  #           - cloud_id: ami_123
  #
  # When specifying images for a PlatformVersion, the cloud_id is
  # required. If an Image already exists with the same cloud_id then
  # it will be used, otherwise a new Image will be created and any
  # extra Image attributes you pass will get used for the creation.
  #
  def self.create_from_yaml_file(file_path)
    yaml = YAML::load_file(file_path)
    yaml['platforms'].each do |platform_yaml|
      platform_versions = platform_yaml.delete('platform_versions') || []
      platform = Platform.new(platform_yaml)
      platform_versions.each do |version_yaml|
        platform.platform_versions << PlatformVersion.new_from_yaml(version_yaml)
      end
      platform.save!
    end
  end
end
