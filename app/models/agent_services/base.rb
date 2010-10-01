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

module AgentServices
  class Base
    
    class << self
      def instance_for_service(service, environment)
        klass = self
        begin
          require "agent_services/#{service.name}"
          klass = "AgentServices::#{service.name.camelize}".constantize
        rescue MissingSourceFile => ex
          Rails.logger.debug "AgentServices::Base.instance_for_service: require failed for agent_services/#{service.name}"
        rescue NameError => ex
          Rails.logger.debug "AgentServices::Base.instance_for_service: constantize failed: #{ex.message}"
        end
        Rails.logger.debug "AgentServices::Base.instance_for_service: using #{klass.name} for #{service.name}"
        klass.new(service, environment)
      end
    end
    
    attr_reader :service, :environment

    def initialize(service, environment)
      @service = service
      @environment = environment
    end

    def deploy(instance_service, deployment)
      #see if the deployment has already been deployed, and bail if so
      return false if instance_service.deployments.exists?(deployment)

      #see if another version of this artifact has been deployed, and
      #udeploy that first if so
      #FIXME: this currently ignores the result of the undeploy operation
      other_deployment = deployment.artifact.deployment_for_instance_service(instance_service)
      undeploy(instance_service, other_deployment) if other_deployment
      
      begin
        result_hash = instance_service.agent_client.deploy_artifact(deployment.artifact_version)
        if result_hash.respond_to?(:[]) and result_hash['artifact_id']
          deployment.update_attribute(:agent_artifact_identifier, result_hash['artifact_id'])
          instance_service.deployments << deployment
          return true
        end
      rescue AgentClient::RequestFailedError => ex
        #TODO: store the failure reason?
        Rails.logger.info "deploying artifact failed: #{ex}"
        Rails.logger.info ex.backtrace.join("\n")
      end

      false
    end

    def undeploy(instance_service, deployment)
      instance_service.agent_client.undeploy_artifact(deployment.agent_artifact_identifier)
      instance_service.deployment_instance_services.find_by_deployment_id(deployment.id).destroy
      true
    rescue AgentClient::RequestFailedError => ex
      #TODO: store the failure reason?
      Rails.logger.info "undeploying artifact failed: #{ex}"
      Rails.logger.info ex.backtrace.join("\n")
      false
    end

    def verify_instance_service(instance_service)
      result = instance_service.agent_client.status
      result['state'] and result['state'] == 'started'
    end

    def configure_instance_service(instance_service)
      #noop, should be overridden in service specific child
      Rails.logger.debug "AgentServices::Base#configure_instance_service called - should #{service.name} have its own configure strategy?"
      true
    end
  end
end
