class GameState
  attr_reader :player, :inventory, :current_room

  def initialize(data)
    @player = data['player']
    @inventory = []
    @current_room = 'start'
    @data = data
  end

  def add_to_inventory(item)
    @inventory << (item.is_a?(Hash) ? item['name'] : item)
  end

  def change_room(new_room)
    @current_room = new_room
  end

  def remove_from_inventory(item)
    @inventory.delete(item)
  end

  def get_room_data(room_name)
    @data['rooms'][room_name]
  end
end
