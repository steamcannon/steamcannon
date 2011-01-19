module SteamCannon
  module API
    class Artifact < AbstractApi

      def versions
        unless @versions
          @versions ||= parse_versions
        end
      end

      def create_version(artifact_file)
        @connector.post(@data['artifact_versions'][0]['href'], "artifact_version[archive]"=>File.new(artifact_file, "rb"))
      end

      protected
      def parse_versions
        @data['artifact_versions'][0]['artifact_version'].collect{|v| ArtifactVersion.new(@connector, v)}
      end
    end
  end
end
