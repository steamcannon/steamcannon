module SteamCannon
  module API

    class AbstractApi
      @data = {}
  
      protected
      def method_missing(m, *args, &block)
        value = @data[m.to_s]
        value.nil? ? "Operation not available" : value
      end
    end
  end
end

