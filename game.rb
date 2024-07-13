require 'optparse'
require_relative 'core/engine'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby game.rb [options]'

  opts.on('--debug', 'Run in debug mode') do
    options[:debug] = true
  end
end.parse!

adventure = Engine.new('./data/game_data.yml')

puts adventure.start

loop do
  print '> '
  input = gets.chomp
  break if input.downcase == 'q'

  if options[:debug]
    response = adventure.handle_input(input)
    puts response
  else
    begin
      response = adventure.handle_input(input)
      puts response
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
      puts 'Please try a different command.'
    end
  end
end

puts 'Thanks for playing!'
