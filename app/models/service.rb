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

class Service < ActiveRecord::Base
  has_many :artifacts
  has_many :instance_services
  has_many :instances, :through => :instance_services
  has_many :required_service_dependencies, :class_name => 'ServiceDependency', :foreign_key => 'dependent_service_id', :dependent => :destroy
  has_many :dependent_service_dependencies, :class_name => 'ServiceDependency', :foreign_key => 'required_service_id', :dependent => :destroy
  has_many :required_services, :through => :required_service_dependencies
  has_many :dependent_services, :through => :dependent_service_dependencies
  has_many :image_services
  has_many :images, :through => :image_services

  validates_presence_of :name
  validates_uniqueness_of :name

  class << self
    def by_name(service_or_name)
      service_or_name.is_a?(Service) ? service_or_name : Service.find_by_name(service_or_name)
    end

    # ---
    # services:
    #  - name: jboss_as
    #    full_name: JBoss AS
    #  - name: mod_cluster
    #    full_name: Mod Cluster
    #    requires:
    #      - jboss_as
    # It is safe to load the same file multiple times - it will not
    # spam the db w/service records.

    def load_from_yaml_file(file_path)
      yaml = YAML::load_file(file_path)
      yaml['services'].each do |service_yaml|
        requires = service_yaml.delete('requires')
        service = Service.find_or_create_by_name(service_yaml)
        service.update_attributes(service_yaml) unless service.new_record?
        service_requirements = service.required_services
        requires && requires.each do |required_service_name|
          required_service = Service.find_or_create_by_name(required_service_name)
          service.required_services << required_service unless service_requirements.include?(required_service)
        end
      end
    end
  end

end

