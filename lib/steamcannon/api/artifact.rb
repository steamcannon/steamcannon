module SteamCannon
  module API
    class Artifact < AbstractApi

      def versions
        unless @versions
          @versions ||= parse_versions
        end
      end

      def parse_versions
        @data['artifact_version'].collect{|v| ArtifactVersion.new(@connector, v)}
      end
    end
  end
end
