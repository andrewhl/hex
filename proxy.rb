require 'rubygems'
require 'eventmachine'
require 'evma_httpserver'
require 'em-http'

class Handler  < EventMachine::Connection
  include EventMachine::HttpServer

  def process_http_request
    resp = EventMachine::DelegatedHttpResponse.new( self )

    http = EventMachine::HttpRequest.new('http://www.google.ca' + @http_path_info).get

    http.callback do
        resp.status = 200
        resp.content = http.response
        resp.send_response
    end

  end
end

EventMachine::run {
  EventMachine::start_server("0.0.0.0", 8082, Handler)
  puts "Listening..."
}
