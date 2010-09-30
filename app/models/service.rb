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

  validates_presence_of :name
  validates_uniqueness_of :name

  def deploy(environment, deployments)
    AgentServices::Base.instance_for_service(self, environment).
      deploy(filter_deployments(deployments))
  end

  def undeploy(deployment)
    AgentServices::Base.instance_for_service(self, deployment.environment).
      undeploy(deployment)
  end

  class << self
    def by_name(service_or_name)
      service_or_name.is_a?(Service) ? service_or_name : Service.find_by_name(service_or_name)
    end
  end
  
  protected
  def filter_deployments(deployments)
    deployments.select { |deployment| deployment.service == self }
  end
end

