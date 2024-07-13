class RoomManager
  def initialize(rooms)
    @rooms = rooms
  end

  def get_current_description(room_name)
    room = @rooms[room_name]
    description = room['description']
    items_description = list_items(room['items'])
    description += "\nItems here: #{items_description}" if items_description != 'None'
    description += "\nMonsters here: " + room['monsters'].keys.join(', ') if room['monsters'] && room['monsters'].any?
    description += "\nAvailable commands: " + available_commands(room).join(', ')
    description
  end

  def get_next_room(current_room, direction)
    @rooms[current_room]['transitions']["go #{direction}"]
  end

  private

  def list_items(items)
    return 'None' if items.nil? || items.empty?

    items.map { |k, v| v.is_a?(Hash) ? v['name'] : k }.join(', ')
  end

  def available_commands(room)
    global_commands = %w[inventory look]
    room_commands = room['commands']&.keys || []
    custom_commands = %w[take drop attack talk use]
    (global_commands + room_commands + custom_commands).uniq
  end
end
