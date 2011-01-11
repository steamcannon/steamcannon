module SteamCannon
  module API
    class Deployment  < AbstractApi
      def initialize(connector, data)
        @connector = connector
        @data = data
      end
    end
  end
end


