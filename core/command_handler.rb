class CommandHandler
  def initialize(game_state, room_manager, item_manager, combat_system)
    @game_state = game_state
    @room_manager = room_manager
    @item_manager = item_manager
    @combat_system = combat_system
  end

  def handle(input)
    command, *args = input.downcase.split

    case command
    when 'go'
      handle_movement(args.first)
    when 'take'
      @item_manager.take_item(args.join(' '), @game_state)
    when 'drop'
      @item_manager.drop_item(args.join(' '), @game_state)
    when 'use'
      @item_manager.use_item(args.join(' '), @game_state)
    when 'attack'
      @combat_system.attack(args.first, @game_state.current_room)
    when 'inventory'
      show_inventory
    when 'look'
      look
    else
      "I don't understand that command."
    end
  end

  private

  def handle_movement(direction)
    new_room = @room_manager.get_next_room(@game_state.current_room, direction)
    if new_room
      @game_state.change_room(new_room)
      @room_manager.get_current_description(new_room)
    else
      "You can't go that way."
    end
  end

  def show_inventory
    items = @game_state.inventory
    items.empty? ? 'Your inventory is empty.' : "You have: #{items.join(', ')}"
  end

  def look
    @room_manager.get_current_description(@game_state.current_room)
  end
end
