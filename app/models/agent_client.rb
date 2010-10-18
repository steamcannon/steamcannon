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
  attr_accessor :service_name

  def initialize(instance, service_name)
    @instance = instance
    @service_name = service_name
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

  def create_cluster_member_address(host, address)
    post 'cluster_member_addresses', :hostname => host, :address => address
  end

  def delete_cluster_member_address(host)
    delete "cluster_member_addresses/#{host}"
  end
  
  ##
  # Service methods
  ##

  %w{ status artifacts }.each do |action|
    define_method action do
      service_get action
    end
  end

  %w{ start stop restart }.each do |action|
    define_method action do
      service_post action
    end
  end

  #TODO: store the artifact_id on the artifact_version locally, and pass the
  #artifact_version AR here
  def artifact(artifact_id)
    service_get "artifacts/#{artifact_id}"
    #service_get "artifacts/#{artifact_version.agent_artifact_id}"
  end

  def deploy_artifact(artifact_version)
    service_post 'artifacts', :artifact => deployment_payload(artifact_version)
  end

  def configure(config)
    service_post 'configure', :config => config
  end

  def undeploy_artifact(artifact_id)
    service_delete "artifacts/#{artifact_id}"
  end

  def logs
    service_get "logs"
  end

  def fetch_log(log_id, num_lines, offset)
    service_get "logs/#{log_id}?num_lines=#{num_lines}&offset=#{offset}"
  end

  protected
  def connection
    if APP_CONFIG[:use_ssl_with_agents]
      options = {
        :ssl_client_cert => Certificate.client_certificate.to_x509_certificate,
        :ssl_client_key => Certificate.client_certificate.to_rsa_keypair,
        :ssl_ca_file => Certificate.ca_certificate.to_public_pem_file,
        :verify_ssl => verify_ssl? ? OpenSSL::SSL::VERIFY_PEER : false
      }
      log "connecting with ssl (verify_ssl: #{options[:verify_ssl]})"
    else
      options = { }
      log "connecting *without* ssl"
    end

    RestClient::Resource.new(agent_url, options)
  end

  def agent_url
    'http' + (APP_CONFIG[:use_ssl_with_agents] ? 's' : '') +  "://#{@instance.public_address}:#{AGENT_PORT}"
  end

  def verify_ssl?
    !@instance.configuring?
  end

  def extract_named_response(action, result)
    # see if result is a hash, and contains a response under the
    # action key
    result.respond_to?(:fetch) ? result.fetch(action, result) : result
  end

  def get(action, options = {})
    extract_named_response(action, call(:get, action, options))
  end

  def service_get(action, options = {})
    extract_named_response(action, service_call(:get, action, options))
  end

  def post(action, body = '', options = {})
    extract_named_response(action, call(:post, action, body, options))
  end

  def service_post(action, body = '', options = {})
    extract_named_response(action, service_call(:post, action, body, options))
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
    call(method, "services/#{@service_name}/#{action}", *args)
  end

  def execute_request
    begin
      response = yield
      response = JSON.parse(response) unless response.blank?
    rescue Exception => ex
      # if the agent is not up, we'll see Errno::ECONNREFUSED
      # if the ssl cert isn't what we expect, we'll see
      # OpenSSL::SSL::SSLError
      log "connection failed: #{ex}"
      log ex.backtrace.join("\n")
      raise RequestFailedError.new("#{last_request} failed", ex.respond_to?(:response) ? ex.response : nil, ex)
    end

    response
  end

  def configure_agent
    post("configure",
         {
           :certificate => @instance.server_certificate.certificate,
           :keypair => @instance.server_certificate.keypair
         })
  end

  def agent_configured?
    @instance.verifying?
  end

  def log(msg)
    Rails.logger.info("AgentClient[Instance:#{@instance.id} (#{@instance.name})]: #{msg}")
  end

  def deployment_payload(artifact_version)
    if artifact_version.supports_pull_deployment?
      { :location => artifact_version.pull_deployment_url }.to_json
    else
      artifact_version.deployment_file
    end
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
