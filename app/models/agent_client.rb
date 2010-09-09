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

  def initialize(instance)
    @instance = instance
  end

  def status
    response = get '/status'
    response = configure_agent if response and response['status'] == 'ok' and !agent_configured?
    response
  end

  def services
    get '/services'
  end

  def get(action, options = {})
    execute_request do
      log "GET #{agent_url}#{action}"
      connection[action].get(options)
    end
  end

  def post(action, body = '', options = {})
    execute_request do
      log "POST #{agent_url}#{action}"
      connection[action].post(body, options)
    end
  end

  protected
  def connection
    options = {
      :ssl_client_cert => Certificate.client_certificate.to_x509_certificate,
      :ssl_client_key => Certificate.client_certificate.to_rsa_keypair,
      :ssl_ca_file => Certificate.ca_certificate.to_public_pem_file,
      :verify_ssl => verify_ssl? ? OpenSSL::SSL::VERIFY_PEER : false
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

  def execute_request
    JSON.parse(yield)
  rescue Exception => ex
    # if the agent is not up, we'll see Errno::ECONNREFUSED
    # if the ssl cert isn't what we expect, we'll see
    # OpenSSL::SSL::SSLError
    # TODO: don't swallow *all* exceptions
    log "connection failed: #{ex}"
    log ex.backtrace.join("\n")
    nil
  end

  def configure_agent
    post("/configure",
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
    Rails.logger.info("AgentClient: #{msg}")
  end
end
