module SteamCannon
  module API
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
