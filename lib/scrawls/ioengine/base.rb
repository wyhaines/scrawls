module Scrawls
  module Ioengine
    class Base

      def run( host = '0.0.0.0', port = '8080' )
        # Implement the main loop of the IO Engine here
      end

      def get_request connection
        # Get the request from the connection. This will pass a lot of responsibility into the httpengine for the actual parsing of the request.
      end

      def handle request
        # Handle the request, and return a response 
      end

    end
  end
end
