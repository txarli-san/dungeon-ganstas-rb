require_relative '../models/player'

class GameState
  attr_reader :player, :current_room

  def initialize(data)
    @player = Player.new(data['player'])
    @current_room = 'start'
    @data = data
  end

  def change_room(new_room)
    @current_room = new_room
  end

  def get_room_data(room_name)
    @data['rooms'][room_name]
  end

  def inventory
    @player.inventory
  end
end
