require 'rubygems'
require 'eventmachine'
require 'evma_httpserver'
require 'em-http'

$waiting_clients = []

class WaitingClient
  attr_reader :resp
  def initialize(resp)
    @resp = resp
  end

  def reply
    resp.status = 200
    resp.content = "Player 2 joined"
    resp.send_response
  end
end

class Handler  < EventMachine::Connection
  include EventMachine::HttpServer

  def process_http_request
    resp = EventMachine::DelegatedHttpResponse.new( self )

    if @http_path_info == '/'
      $waiting_clients << WaitingClient.new(resp)
      puts "Clients waiting: #{$waiting_clients.length}"
    elsif @http_path_info == '/join'
      $waiting_clients.each { |client| puts "Client"; client.reply }
      $waiting_clients = []
      resp.status = 200
      resp.content = "Hi player 2"
      resp.send_response
      puts "Replied to all clients"
    else
      puts "Invalid request #{@http_path_info}"
    end
  end
end

EventMachine::run {
  EventMachine::start_server("0.0.0.0", 8082, Handler)
  puts "Listening..."
}
