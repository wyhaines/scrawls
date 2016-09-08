require 'rack/content_length'
require 'rack/rewindable_input'

# This is barebones and terrible. TODO: Make it less terrible.
module Rack
  module Handler
    class Scrawls
      def self.serve(app, request, ioengine)
        status, headers, body = app.call(request)
        begin
          send_headers ioengine, status, headers
          send_body ioengine, body
        ensure
          body.close  if body.respond_to? :close
        end
      end

      def self.send_headers(ioengine, status, headers)
        headers.each { |k, vs|
          vs.split("\n").each { |v|
            ioengine.send_data "#{k}: #{v}\r\n"
          }
        }
        ioengine.send_data "\r\n"
      end

      def self.send_body(ioengine, body)
        body.each { |part|
          ioengine.send_data part
        }
      end
    end
  end
end
