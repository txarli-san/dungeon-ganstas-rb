require 'byebug'
require_relative 'engine'
adventure = TextAdventure.new('./data/game_data.yml')

puts adventure.start

loop do
  print '> '
  input = gets.chomp
  break if input.downcase == 'q'

  response = adventure.handle_input(input)
  puts response
end

puts 'Thanks for playing!'
