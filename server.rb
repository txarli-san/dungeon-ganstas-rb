require 'socket'
require_relative 'core/engine'

server = TCPServer.new 10_000

def handle_client(client)
  loop do
    input = client.gets
    if input.nil?
      puts 'Client disconnected'
      break
    end
    input.chomp!
    # Process the input here
    puts "Received: #{input}"
  rescue Errno::ECONNRESET
    puts 'Connection reset by peer'
    break
  rescue StandardError => e
    puts "Error: #{e.message}"
    break
  end
  client.close
end

puts 'Telnet server started on port 2323'

loop do
  Thread.start(server.accept) do |client|
    handle_client(client)
  end
end
