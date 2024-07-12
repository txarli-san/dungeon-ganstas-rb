require 'yaml'
require_relative 'lib/console_output'
require_relative 'lib/world'

class Engine
  def initialize(data_file)
    @data = World.generate(YAML.load_file(data_file))
    @current_state = 'start'
    @inventory = []
    @player = @data['player']
    @items = @data['items'] || {}

    populate_items_from_rooms
  end

  def populate_items_from_rooms
    @data['rooms'].each do |_, room|
      room['items'].each do |item_key, item_data|
        @items[item_key] = item_data unless @items.key?(item_key)
      end
    end
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
    if input.downcase == 'inventory'
      ConsoleOutput.print show_inventory
      return true
    end

    commands = @data['global_commands'].merge(@data['rooms'][@current_state]['commands'] || {})
    command_response = commands[input.downcase]

    if input.start_with?('take ') || input.start_with?('drop ') || input.start_with?('attack ')
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
    when /^talk/
      response = talk(command.split(' ')[1])
    when /^use/
      response = use_item(command.split(' ')[1])
    else
      response ||= "I don't understand that command."
    end

    ConsoleOutput.print response
  end

  def attack(target = nil)
    monsters = @data['rooms'][@current_state]['monsters']
    return 'There are no monsters here to attack.' unless monsters&.any?

    if target.nil?
      unless monsters.keys.length == 1
        return "Which monster do you want to attack? Options: #{monsters.keys.join(', ')}"
      end

      target = monsters.keys.first

    end

    return "There's no #{target} here to attack." unless monsters.key?(target)

    monster = monsters[target]
    damage_dealt = @player['strength'] - (monster['defense'] || 0)
    damage_dealt = 1 if damage_dealt < 1

    monster['health'] -= damage_dealt
    response = "You attack the #{target} for #{damage_dealt} damage!"

    if monster['health'] <= 0
      monsters.delete(target)
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

  def talk(target)
    monsters = @data['rooms'][@current_state]['monsters']
    return "There's no one here to talk to." unless monsters&.key?(target)

    dialogue = @data['rooms'][@current_state]['commands']["talk to #{target}"]
    dialogue || "The #{target} doesn't respond."
  end

  def use_item(item_name)
    item = @inventory.find do |i|
      i.is_a?(Hash) ? i['name'].downcase == item_name.downcase : i.downcase == item_name.downcase
    end
    return "You don't have a #{item_name} in your inventory." unless item

    item_data = item.is_a?(Hash) ? item : @items[item]
    return "You can't use the #{item_name}." unless item_data

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
    state = @data['rooms'][@current_state]
    description = state['description']
    description += "\nItems here: " + list_items(state['items']) if state['items']&.any?
    description += "\nMonsters here: " + state['monsters'].keys.join(', ') if state['monsters']&.any?
    description
  end

  def list_items(items)
    return 'None' if items.nil? || items.empty?

    items.values.compact.map { |item| item['name'] }.join(', ')
  end

  def show_inventory
    if @inventory.empty?
      'Your inventory is empty.'
    else
      'You have: ' + @inventory.map { |item| item.is_a?(Hash) ? item['name'] : item }.join(', ')
    end
  end

  def print_help
    'Available commands: ' + available_commands.join(', ')
  end

  def take_item_from_room(command, _response)
    item_name = command.split(' ', 2)[1]
    room_items = @data['rooms'][@current_state]['items']

    return "There's no #{item_name} here to take." if room_items.nil? || room_items.empty?

    item_key = room_items.keys.find { |k| k.gsub('_', ' ').downcase == item_name.downcase }

    if item_key
      item = room_items[item_key]
      @inventory << (item.is_a?(Hash) ? item : item_key)
      room_items.delete(item_key)
      "You take the #{item.is_a?(Hash) ? item['name'] : item_key.gsub('_', ' ')}."
    else
      "There's no #{item_name} here to take."
    end
  end

  def drop_item_in_room(command, _response)
    item_name = command.split(' ', 2)[1]
    item = @inventory.find do |i|
      i.is_a?(Hash) ? i['name'].downcase == item_name.downcase : i.downcase == item_name.downcase
    end
    if item
      @inventory.delete(item)
      @data['rooms'][@current_state]['items'] ||= {}
      item_key = item.is_a?(Hash) ? item['name'].downcase.gsub(' ', '_') : item.downcase.gsub(' ', '_')
      @data['rooms'][@current_state]['items'][item_key] = item
      "You drop the #{item.is_a?(Hash) ? item['name'] : item}."
    else
      "You don't have a #{item_name} to drop."
    end
  end

  def get_current_description
    state = @data['rooms'][@current_state]
    description = state['description']
    items_description = list_items(state['items'])
    description += "\nItems here: #{items_description}" if items_description != 'None'
    if state['monsters'] && state['monsters'].any?
      description += "\nMonsters here: " + state['monsters'].keys.join(', ')
    end
    description += "\nAvailable commands: " + available_commands.join(', ')
    description
  end

  def list_items(items)
    return 'None' if items.nil? || items.empty?

    items.map { |k, v| v.is_a?(Hash) ? v['name'] : k }.join(', ')
  end

  def stats
    "Your stats:\nHP: #{@player['health']}/#{@player['max_health']}\nStrength: #{@player['strength']}\nDefense: #{@player['defense']}"
  end

  def available_commands
    global_commands = @data['global_commands'].keys
    room_commands = @data['rooms'][@current_state]['commands']&.keys || []
    custom_commands = %w[take drop attack talk use stats]
    (global_commands + room_commands + custom_commands).uniq
  end
end
