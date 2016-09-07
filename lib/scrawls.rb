require 'scrawls/core'

module Scrawls
  def run
    config = SimpleRubyWebServer::Config.new
    config.parse_cmdline
    server = SimpleRubyWebServer.new config
    server.run
  end
end
