require 'restclient'
require 'xmlsimple'
require 'base64'

module SteamCannon
  module API
    class Connector
      attr_accessor :login, :pass

      def initialize(login, pass)
        @login, @pass = login, pass
      end

      def default_headers
        auth_header = "Basic "+Base64.encode64("#{@login}:#{@pass}")
        auth_header.gsub!("\n", "")
        {
          :authorization => auth_header,
          :accept => "text/xml",
          :x_requested_with => 'XMLHttpRequest' # Make protect_from_forgery happy
        }
      end

      def request(url, options = {'KeyAttr' => ['rel']})
        response = RestClient.get(url.to_s, default_headers)
        XmlSimple.xml_in(response.dup, options)
      end

      def post(url, data = {})
        RestClient.post(url, data, default_headers)
      end
    end
  end
end

