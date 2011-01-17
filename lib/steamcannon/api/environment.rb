module SteamCannon
  module API
    class Environment < AbstractApi
      def deltacloud_url
        @data['link']['deltacloud_endpoint']['href']
      end

      def can_launch?
        !@data['actions'][0]['link']['start'].nil?
      end

      def can_stop?
        !@data['actions'][0]['link']['stop'].nil?
      end

      def stop
        @connector.post(@data['actions'][0]['link']['stop']['href'])
      end

      def launch
        @connector.post(@data['actions'][0]['link']['start']['href'])
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

