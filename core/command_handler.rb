class CommandHandler
  def initialize(game_state, room_manager, item_manager, combat_system)
    @game_state = game_state
    @room_manager = room_manager
    @item_manager = item_manager
    @combat_system = combat_system
  end

  def handle(input)
    command, *args = input.downcase.split
    room_data = @game_state.get_room_data(@game_state.current_room)
    available_commands = get_available_commands(room_data)

    if available_commands.include?(command) || (command == 'go' && available_commands.include?("go #{args.first}"))
      execute_command(command, args)
    else
      invalid_command_message(available_commands)
    end
  end

  def get_available_commands(room_data)
    commands = %w[look inventory stats use]
    commands += ['take'] if room_data['items']&.any?
    commands += ['attack'] if room_data['monsters']&.any?
    commands += room_data['transitions'].keys if room_data['transitions']
    commands += room_data['commands'].keys if room_data['commands']
    commands.uniq
  end

  private

  def execute_command(command, args)
    case command
    when 'go'      then handle_movement(args.first)
    when 'take'    then @item_manager.take_item(args.join(' '), @game_state)
    when 'drop'    then @item_manager.drop_item(args.join(' '), @game_state)
    when 'use'     then @item_manager.use_item(args.join(' '), @game_state)
    when 'attack'  then @combat_system.attack(args.first, @game_state.current_room)
    when 'inventory' then show_inventory
    when 'look'    then look
    when 'stats'   then @game_state.player.display_stats
    else                invalid_command_message(get_available_commands(@game_state.get_room_data(@game_state.current_room)))
    end
  end

  def invalid_command_message(available_commands)
    "I don't understand that command. Available commands: #{available_commands.join(', ')}"
  end

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
    items = @game_state.inventory.items
    items.empty? ? 'Your inventory is empty.' : "You have: #{items.map(&:name).join(', ')}"
  end

  def look
    @room_manager.get_current_description(@game_state.current_room)
  end
end
