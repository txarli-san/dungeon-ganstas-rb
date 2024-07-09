require 'yaml'
require_relative 'lib/console_output'

class TextAdventure
  def initialize(data_file)
    @data = YAML.load_file(data_file)
    @current_state = 'start'
    @inventory = []
    @player = @data['player']
    @items = @data['items'] || {}
  end

  def start
    get_current_description
  end

  def handle_input(input)
    return if handle_command(input)

    next_state = @data['rooms'][@current_state]['transitions'][input.downcase]
    if next_state
      @current_state = next_state
      ConsoleOutput.print get_current_description
    else
      ConsoleOutput.print "I don't understand that command."
    end
  end

  def handle_command(input)
    commands = @data['global_commands'].merge(@data['rooms'][@current_state]['commands'] || {})
    command_response = commands[input.downcase]

    if input.start_with?('take ') || input.start_with?('drop ')
      execute_command(input.downcase, nil)
      return true
    end

    return false unless command_response

    execute_command(input.downcase, command_response)
    true
  end

  def execute_command(command, response)
    case command
    when /^take/
      response = take_item_from_room(command, response)
    when /^drop/
      response = drop_item_in_room(command, response)
    when 'help'
      response = print_help
    when 'inventory'
      response = show_inventory
    when 'look'
      response = look
    when /^attack/
      response = attack(command.split(' ')[1])
    when /^use/
      response = use_item(command.split(' ')[1])
    else
      response ||= "I don't understand that command."
    end

    ConsoleOutput.print response
  end

  def attack(target)
    return "There's no #{target} here to attack." unless @data['rooms'][@current_state]['monsters']&.key?(target)

    monster = @data['rooms'][@current_state]['monsters'][target]
    damage_dealt = @player['strength'] - (monster['defense'] || 0)
    damage_dealt = 1 if damage_dealt < 1

    monster['health'] -= damage_dealt
    response = "You attack the #{target} for #{damage_dealt} damage!"

    if monster['health'] <= 0
      @data['rooms'][@current_state]['monsters'].delete(target)
      response += " The #{target} is defeated!"
    else
      monster_damage = (monster['attack'] || 0) - @player['defense']
      monster_damage = 1 if monster_damage < 1
      @player['health'] -= monster_damage
      response += " The #{target} counterattacks for #{monster_damage} damage!"

      response += ' You have been defeated. Game over!' if @player['health'] <= 0
    end

    response
  end

  def use_item(item_name)
    item = @inventory.find { |i| i == item_name }
    return "You don't have a #{item_name} in your inventory." unless item

    item_data = @data['items'][item_name]
    case item_data['type']
    when 'consumable'
      use_consumable(item_name, item_data)
    when 'weapon'
      equip_weapon(item_name, item_data)
    when 'armor'
      equip_armor(item_name, item_data)
    else
      "You can't use the #{item_name}."
    end
  end

  def use_consumable(item_name, item_data)
    return unless item_data['effect']['health']

    @player['health'] += item_data['effect']['health']
    @player['health'] = [@player['health'], @player['max_health']].min
    @inventory.delete(item_name)
    "You use the #{item_name} and restore #{item_data['effect']['health']} health."
  end

  def equip_weapon(item_name, item_data)
    @player['strength'] = 10 + item_data['damage']
    "You equip the #{item_name}. Your strength is now #{@player['strength']}."
  end

  def equip_armor(item_name, item_data)
    @player['defense'] = 5 + item_data['defense']
    "You equip the #{item_name}. Your defense is now #{@player['defense']}."
  end

  def look
    @data['rooms'][@current_state]['description']
  end

  def show_inventory
    'You have: ' + @inventory.join(', ')
  end

  def print_help
    'Available commands: ' + available_commands.join(', ')
  end

  def take_item_from_room(command, _response)
    item = command.split(' ')[1]
    if @data['rooms'][@current_state]['items']&.include?(item)
      @inventory << item
      @data['rooms'][@current_state]['items'].delete(item)
      "You take the #{item}."
    else
      "There's no #{item} here to take."
    end
  end

  def drop_item_in_room(command, _response)
    item = command.split(' ')[1]
    if @inventory.include?(item)
      @inventory.delete(item)
      @data['rooms'][@current_state]['items'] ||= []
      @data['rooms'][@current_state]['items'] << item
      "You drop the #{item}."
    else
      "You don't have a #{item} to drop."
    end
  end

  def get_current_description
    state = @data['rooms'][@current_state]
    description = state['description']
    description += "\nItems here: " + state['items'].join(', ') if state['items'] && state['items'].any?
    if state['monsters'] && state['monsters'].any?
      description += "\nMonsters here: " + state['monsters'].keys.join(', ')
    end
    description += "\nAvailable commands: " + available_commands.join(', ')
    description
  end

  def available_commands
    global_commands = @data['global_commands'].keys
    room_commands = @data['rooms'][@current_state]['commands']&.keys || []
    global_commands + room_commands
  end
end
