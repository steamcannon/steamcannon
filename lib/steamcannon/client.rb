require File.join(File.dirname(__FILE__), 'api', 'abstract_api')
require File.join(File.dirname(__FILE__), 'api', 'connector')
require File.join(File.dirname(__FILE__), 'api', 'artifact')
require File.join(File.dirname(__FILE__), 'api', 'deployment')
require File.join(File.dirname(__FILE__), 'api', 'environment')

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
  end
end




