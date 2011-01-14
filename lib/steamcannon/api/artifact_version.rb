module SteamCannon
  module API
    class ArtifactVersion < AbstractApi 

      def deployments
        @deployments ||= parse_deployments
      end

      protected
      def parse_deployments
        collection = []
        unless @data['deployment'].nil?
          @data['deployment'].each { |d| collection << Deployment.new(@connector, d) }
        end
        collection
      end
    end
  end
end
