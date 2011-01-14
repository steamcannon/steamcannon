module SteamCannon
  module API
    class AbstractApi
      @data = {}

      def initialize(connector, data)
        @connector = connector
        @data = data
      end
  
      def id
        @data['id'].nil? ? super : @data['id']
      end

      protected
      def method_missing(m, *args, &block)
        @data[m.to_s]
      end
    end
  end
end

