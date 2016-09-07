require 'scrawls/core'

module Scrawls
  def self.run
    config = SimpleRubyWebServer::Config.new
    config.parse
    server = SimpleRubyWebServer.new config
    server.run
  end
end
