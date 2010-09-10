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

class AgentClient
  AGENT_PORT = 7575

  attr_accessor :last_request

  def initialize(instance, service)
    @instance = instance
    @service = service
  end

  ##
  # Global agent methods
  ##
  
  def agent_status
    response = get 'status'
    configure_agent if !agent_configured?
    response
  end

  def agent_services
    get 'services'
  end

  ##
  # Service methods
  ##

  %w{ status start stop restart artifacts }.each do |action|
    define_method action do
      service_get action
    end
  end
  
  #TODO: store the artifact_id on the artifact_version locally, and pass the
  #artifact_version AR here
  def artifact(artifact_id)
    service_get "artifacts/#{artifact_id}"
    #service_get "artifacts/#{artifact_version.agent_artifact_id}"
  end

  def deploy_artifact(artifact_version)
    service_post 'artifacts', :artifact => File.new(artifact_version.archive.path, 'r')
  end

  def configure(config)
    service_post 'configure', :config => config
  end

  #TODO: store the artifact_id on the artifact_version locally, and pass the
  #artifact_version AR here
  def undeploy_artifact(artifact_id)
    service_delete "artifacts/#{artifact_id}"
  end

  protected
  def connection
    options = {
      :ssl_client_cert => Certificate.client_certificate.to_x509_certificate,
      :ssl_client_key => Certificate.client_certificate.to_rsa_keypair,
      :ssl_ca_file => Certificate.ca_certificate.to_public_pem_file,
      :verify_ssl => false #FIXME: once agent reconfigures: verify_ssl? ? OpenSSL::SSL::VERIFY_PEER : false
    }
    log "connecting (verify_ssl: #{options[:verify_ssl]})"

    RestClient::Resource.new(agent_url, options)
  end

  def agent_url
    "https://#{@instance.public_dns}:#{AGENT_PORT}"
  end

  def verify_ssl?
    !@instance.configuring?
  end

  def get(action, options = {})
    call(:get, action, options)
  end

  def service_get(action, options = {})
    service_call(:get, action, options)
  end
  
  def post(action, body = '', options = {})
    call(:post, action, body, options)
  end

  def service_post(action, body = '', options = {})
    service_call(:post, action, body, options)
  end

  def delete(action, options = {})
    call(:delete, action, options)
  end

  def service_delete(action, options = {})
    service_call(:delete, action, options)
  end

  def call(method, action, *args)
    execute_request do
      log(self.last_request = "#{method.to_s.upcase} #{agent_url}/#{action}")
      connection["/#{action}"].send(method, *args)
    end
  end

  def service_call(method, action, *args)
    call(method, "services/#{@service}/#{action}", *args)
  end
  
  def execute_request
    begin
      response = JSON.parse(yield)
    rescue Exception => ex
      # if the agent is not up, we'll see Errno::ECONNREFUSED
      # if the ssl cert isn't what we expect, we'll see
      # OpenSSL::SSL::SSLError
      log "connection failed: #{ex}"
      log ex.backtrace.join("\n")
      raise RequestFailedError.new("#{last_request} failed", nil, ex)
    end

    raise RequestFailedError.new("#{last_request} failed", response) if response['status'] != 'ok'
    
    response
  end

  def configure_agent
    post("configure",
         {
           :certificate => @instance.server_certificate.certificate,
           :keypair => @instance.server_certificate.keypair,
           :ca => Certificate.ca_certificate.certificate
         })
  end

  def agent_configured?
    @instance.verifying?
  end

  def log(msg)
    Rails.logger.info("AgentClient[Instance:#{@instance.id}]: #{msg}")
  end

  class RequestFailedError < StandardError
    attr_reader :response, :wrapped_exception
    def initialize(msg, response = nil, wrapped_exception = nil)
      super(msg)
      @response = response
      @wrapped_exception = wrapped_exception
    end
  end
end
