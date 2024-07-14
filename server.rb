require 'socket'
require_relative 'core/engine'

server = TCPServer.new 2323

def handle_client(client)
  adventure = Engine.new('./data/game_data.yml')
  client.puts adventure.start

  loop do
    client.print '> '
    input = client.gets.chomp
    break if input.downcase == 'quit'

    response = adventure.handle_input(input)
    client.puts response
  end

  client.puts 'Thanks for playing!'
  client.close
end

puts 'Telnet server started on port 2323'

loop do
  Thread.start(server.accept) do |client|
    handle_client(client)
  end
end
