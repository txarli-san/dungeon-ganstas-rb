require 'em-websocket'
require_relative 'core/engine'
require_relative 'core/game_view'

EM.run do
  @adventures = {}

  EM::WebSocket.run(host: '0.0.0.0', port: 8080) do |ws|
    ws.onopen do |_handshake|
      puts 'WebSocket connection open'
      @adventures[ws] = Engine.new('./data/game_data.yml')
      initial_response = @adventures[ws].start
      ws.send(GameView.format_response(@adventures[ws], initial_response))
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
      ws.send(GameView.format_response(@adventures[ws], response))
    end
  end
end
