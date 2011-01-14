module SteamCannon
  module API
    class Environment < AbstractApi
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
  end
end

