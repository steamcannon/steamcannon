module SteamCannon
  module API
    class Artifact < AbstractApi

      def versions
        unless @versions
          @versions ||= parse_versions
        end
      end

      def create_version(data)
        puts "This part isn't done yet - but when it is, we'll upload #{data}"
      end

      protected
      def parse_versions
        @data['artifact_versions'][0]['artifact_version'].collect{|v| ArtifactVersion.new(@connector, v)}
      end
    end
  end
end
