require 'scrawls/version'
require 'scrawls/config'
require 'time'

class SimpleRubyWebServer

  CANNED_OK = "HTTP/1.0 200 OK\r\n"

  attr_accessor :io_engine, :http_engine

  def initialize(config)
    @config = config
  end

  def run(&block)
    @http_engine = @config[:httpengine]

    @io_engine = @config[:ioengine].new self

    @io_engine.run @config
  end

  def process request, connection
    # This server is stupid. For any request method, and http version, it just tries to serve a static file.
    path = File.join( @config[:docroot], request['PATH_INFO'] )
    if FileTest.directory? path
      deliver_directory path, connection
    elsif FileTest.exist?( path ) and FileTest.file?( path ) and File.expand_path( path ).index( File.expand_path( @config[:docroot] ) ) == 0
      connection.write CANNED_OK +
          "Content-Type: #{MIME::Types.type_for( path )}\r\n" +
          "Content-Length: #{File.size( path )}\r\n" +
          "Last-Modified: #{File.mtime( path )}\r\n" +
          final_headers +
          File.read( path )
    else
      deliver_404 connection
    end
  rescue Exception => e
    puts "ERROR\n\n#{e}\n#{e.backtrace.join("\n")}\n"
    deliver_500 connection
  end

  def final_headers
    "Date: #{Time.now.httpdate}\r\nConnection: close\r\n\r\n"
  end

  def deliver_directory path, connection
    deliver_403 connection
  end

  def deliver_404 uri, connection
    buffer = "The requested resource (#{uri}) could not be found."
    connection.write "HTTP/1.1 404 Not Found\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n#{final_headers}#{buffer}"
  end

  def deliver_400 connection
    buffer = "The request was malformed and could not be completed."
    connection.write "HTTP/1.1 400 Bad Request\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n#{final_headers}#{buffer}"
  end

  def deliver_403 connection
    buffer = "Forbidden. The requested resource can not be accessed."
    connection.write "HTTP/1.1 403 Bad Request\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n#{final_headers}#{buffer}"
  end

  def deliver_500 connection
    buffer = "There was an internal server error."
    connection.write "HTTP/1.1 500 Bad Request\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n#{final_headers}#{buffer}"
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
