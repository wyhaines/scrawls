require 'scrawls/version'
require 'scrawls/config'
require 'scrawls/rack_handler'
require 'time'

class SimpleRubyWebServer

  CANNED_OK = "HTTP/1.0 200 OK\r\n"

  attr_accessor :io_engine, :http_engine

  def initialize(config)
    @config = config
  end

  def run(&block)
    @rack_app = SimpleRubyWebServer.rack_app if @config[:racked]

    @http_engine = @config[:httpengine]

    @io_engine = @config[:ioengine].new self

    @io_engine.run @config
  end

  def has_app?
    @rack_app
  end

  def run_app request, ioengine
    ::Rack::Handler::Scrawls.serve @rack_app, request, ioengine
  end

  def process request, ioengine
    # This server is stupid. For any request method, and http version, it just tries to serve a static file.
    path = File.join( @config[:docroot], request['PATH_INFO'] )
    if FileTest.directory? path
      deliver_directory path, ioengine
    elsif FileTest.exist?( path ) and FileTest.file?( path ) and File.expand_path( path ).index( File.expand_path( @config[:docroot] ) ) == 0
      ioengine.send_data CANNED_OK +
          "Content-Type: #{MIME::Types.type_for( path )}\r\n" +
          "Content-Length: #{File.size( path )}\r\n" +
          "Last-Modified: #{File.mtime( path )}\r\n" +
          final_headers +
          File.read( path )
    elsif has_app?
      run_app request, ioengine
    else
      deliver_404 ioengine
    end
  rescue Exception => e
    puts "ERROR\n\n#{e}\n#{e.backtrace.join("\n")}\n"
    deliver_500 ioengine
  end

  def final_headers
    "Date: #{Time.now.httpdate}\r\nConnection: close\r\n\r\n"
  end

  def deliver_directory path, ioengine
    deliver_403 ioengine
  end

  def deliver_404 uri, ioengine
    buffer = "The requested resource (#{uri}) could not be found."
    ioengine.send_data "HTTP/1.1 404 Not Found\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n#{final_headers}#{buffer}"
  end

  def deliver_400 ioengine
    buffer = "The request was malformed and could not be completed."
    ioengine.send_data "HTTP/1.1 400 Bad Request\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n#{final_headers}#{buffer}"
  end

  def deliver_403 ioengine
    buffer = "Forbidden. The requested resource can not be accessed."
    ioengine.send_data "HTTP/1.1 403 Bad Request\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n#{final_headers}#{buffer}"
  end

  def deliver_500 ioengine
    buffer = "There was an internal server error."
    ioengine.send_data "HTTP/1.1 500 Bad Request\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n#{final_headers}#{buffer}"
  end

  def content_type_for path
    MIME::TinyTypes.types.simple_type_for( path ) || 'application/octet-stream'
  end

  def data_for path_info
    path = File.join(@docroot,path_info)
    path if FileTest.exist?(path) and FileTest.file?(path) and File.expand_path(path).index(docroot) == 0		
  end

  def final_headers
    "Date: #{Time.now.httpdate}\r\nConnection: close\r\n\r\n"
  end

end
