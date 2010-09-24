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
  class DefaultService
    
    class << self
      def instance_for_service(service, environment)
        class_name = "#{service.name.camelize}Service"
        klass = "AgentServices::#{class_name}".constantize if AgentServices.const_defined?(class_name)
        klass ||= self
        klass.new(service, environment)
      end
    end
    
    attr_reader :service, :environment

    def initialize(service, environment)
      @service = service
      @environment = environment
    end

    def deploy(deployments)
      instances = instances_for_deploy

      return false if instances.empty?
      
      deployments.each do |deployment|
        remote_artifact_id = nil
        success = instances.inject(true) do |accumulated_success, instance|
          result = deploy_to_instance(instance, deployment)
          remote_artifact_id ||= result
          accumulated_success && result
        end

        deployment.agent_artifact_identifier = remote_artifact_id
        
        success ? deployment.mark_as_deployed! : deployment.fail!
        
        success
      end
    end

    def deploy_to_instance(instance, deployment)
      response = false
      begin
        result_hash = instance.agent_client(service).deploy_artifact(deployment.artifact_version)
        if result_hash.respond_to?(:[]) and result_hash['artifact_id']
          response =  result_hash['artifact_id']
        end
      rescue AgentClient::RequestFailedError => ex
        #TODO: store the failure reason?
        Rails.logger.info "deploying artifact failed: #{ex}"
        Rails.logger.info ex.backtrace.join("\n")
      end

      response
    end

    def instances_for_deploy
      service.instances.running.in_environment(environment)
    end
  end

end
