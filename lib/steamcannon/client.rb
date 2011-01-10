require 'restclient'
require 'xmlsimple'
require 'base64'

module SteamCannon
  module API
    class Connector
      attr_accessor :login, :pass

      def initialize(login, pass)
        @login, @pass = login, pass
      end

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

    end

    class AbstractApi
      @data = {}
  
      protected
      def method_missing(m, *args, &block)
        value = @data[m.to_s]
        value.nil? ? "Operation not available" : value
      end
    end

    class Client < AbstractApi

      def initialize(url, login, pass)
        @url        = url
        @endpoint   = URI.parse(@url)
        @connector  = Connector.new(login, pass)
        fetch_endpoint
      end

      def environments
        @environments ||= fetch_environments
      end

      def artifacts
        @artifacts ||= fetch_artifacts
      end

      def cloud_profiles
        puts "Not done yet. File a Jira or something."
      end

      protected
      def fetch_endpoint
        response            = @connector.request(@endpoint)
        @environments_url   = response['link']['environments']['href']
        @artifacts_url      = response['link']['artifacts']['href']
        @cloud_profiles_url = response['link']['cloud_profiles']['href']
      end

      def fetch_environments
        @connector.request(@environments_url)['environment'].collect{|e|Environment.new(@connector, e)}
      end

      def fetch_artifacts
        @connector.request(@artifacts_url)['artifact'].collect { |a| Artifact.new(@connector, a) }
      end
    end

    class Environment < AbstractApi
      def initialize(connector, data)
        @connector = connector
        @data = data
      end

      def deltacloud_url
        @data['link']['deltacloud_endpoint']['href']
      end
  
      def deployments
        unless @deployments
          response = @connector.request(@data['deployments'][0]['href'])['deployment']
          @deployments = response.nil? ? [] : response.collect{|d|Deployment.new(self, d)}
        end
        @deployments 
      end
    end

    class Deployment  < AbstractApi
      def initialize(connector, data)
        @connector = connector
        @data = data
      end
    end

    class Artifact < AbstractApi
      def initialize(connector, data)
        @connector = connector
        @data = data
      end

      def versions
        unless @versions
          @versions = @data['artifact_version'].collect{|v| v['href']}
        end
      end
    end
  end
end




