require 'restclient'
require 'xmlsimple'
require 'base64'

module SteamCannon
  module API
    class AbstractApi
      attr_accessor :login, :pass
      @data = {}
  
      def default_headers
        auth_header = "Basic "+Base64.encode64("#{@login}:#{@pass}")
        auth_header.gsub!("\n", "")
        {
          :authorization => auth_header,
          :accept => "text/xml"
        }
      end
  
      def request(url, options = {'KeyAttr' => ['rel']})
        XmlSimple.xml_in(RestClient.send(:get, url.to_s, default_headers).dup, options)
      end

      protected
      def method_missing(m, *args, &block)
        value = @data[m.to_s]
        value.nil? ? "Operation not available" : value
      end
    end

    class Client < AbstractApi

      def initialize(url, login, pass)
        @endpoint   = URI.parse(url)
        @login      = login
        @pass       = pass
        @url        = url
        fetch_endpoint
      end

      def environments
        @environments ||= request(@environments_url)['environment'].collect{|e|Environment.new(self, e)}
      end

      def artifacts
        @artifacts ||= fetch_artifacts
      end

      def cloud_profiles
        puts "Not done yet. File a Jira or something."
      end

      protected
      def fetch_endpoint
        response            = request(@endpoint)
        @environments_url   = response['link']['environments']['href']
        @artifacts_url      = response['link']['artifacts']['href']
        @cloud_profiles_url = response['link']['cloud_profiles']['href']
      end

      def fetch_artifacts
        request(@artifacts_url)['artifact'].collect { |artifact| @artifacts << artifact }
      end
    end

    class Environment < AbstractApi
      def initialize(client, data)
        @login = client.login
        @pass = client.pass
        @data = data
      end

      def deltacloud_url
        @data['link']['deltacloud_endpoint']['href']
      end
  
      def deployments
        @deployments ||= request(@data['deployments'][0]['href'])['deployment'].collect{|d|Deployment.new(self, d)}
      end
    end

    class Deployment  < AbstractApi
      def initialize(client, data)
        @login = client.login
        @pass = client.pass
        @data = data
      end
    end
  end
end




