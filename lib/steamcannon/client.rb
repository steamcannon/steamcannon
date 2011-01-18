require File.join(File.dirname(__FILE__), 'api', 'abstract_api')
require File.join(File.dirname(__FILE__), 'api', 'connector')
require File.join(File.dirname(__FILE__), 'api', 'artifact')
require File.join(File.dirname(__FILE__), 'api', 'artifact_version')
require File.join(File.dirname(__FILE__), 'api', 'deployment')
require File.join(File.dirname(__FILE__), 'api', 'environment')
require File.join(File.dirname(__FILE__), 'api', 'platform')

module SteamCannon
  module API
    class Client < AbstractApi
      def initialize(url, login, pass)
        @url        = url
        @endpoint   = URI.parse(@url)
        @connector  = Connector.new(login, pass)
        fetch_endpoint
      end

      def environments
        @environments ||= fetch(@environments_url, 'environment', Environment)
      end

      def artifacts
        @artifacts ||= fetch(@artifacts_url, 'artifact', Artifact)
      end

      def platforms
        @platforms ||= fetch(@platforms_url, 'platform', Platform)
      end

      def cloud_profiles
        @cloud_profiles ||= fetch(@cloud_profiles_url, 'cloud_profile', CloudProfile)
      end

      protected
      def fetch_endpoint
        response            = @connector.request(@endpoint)
        @environments_url   = response['link']['environments']['href']
        @artifacts_url      = response['link']['artifacts']['href']
        @cloud_profiles_url = response['link']['cloud_profiles']['href']
        @platforms_url      = response['link']['platforms']['href']
      end

      def fetch(url, key, clazz)
        response = @connector.request(url)[key]
        response.nil? ? [] : response.collect { |p| clazz.new(@connector, p) }
      end
    end
  end
end





