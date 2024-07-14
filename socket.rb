require 'em-websocket'
require 'eventmachine'
require_relative 'core/engine'

EM.run do
  @adventures = {}

  EM::WebSocket.run(host: '0.0.0.0', port: 8080) do |ws|
    ws.onopen do |_handshake|
      puts 'WebSocket connection open'
      @adventures[ws] = Engine.new('./data/game_data.yml')
      ws.send(@adventures[ws].start)
    end

    ws.onclose { puts 'Connection closed' }

    ws.onmessage do |msg|
      puts "Received message: #{msg}"
      msg = msg.strip
      response = if msg.empty?
                   'Please enter a command.'
                 else
                   @adventures[ws].handle_input(msg)
                 end
      ws.send(response)
    end
  end
end
