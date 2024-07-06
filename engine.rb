require 'yaml'

class TextAdventure
  def initialize(data_file)
    @data = YAML.load_file(data_file)
    @current_state = 'start'
    @inventory = []
  end

  def start
    get_current_description
  end

  def handle_input(input)
    return if handle_command(input)

    next_state = @data['rooms'][@current_state]['transitions'][input.downcase]
    if next_state
      @current_state = next_state
      puts get_current_description
    else
      puts "I don't understand that command."
    end
  end

  def handle_command(input)
    commands = @data['global_commands'].merge(@data['rooms'][@current_state]['commands'] || {})
    command_response = commands[input.downcase]

    if command_response
      execute_command(input.downcase, command_response)
      true
    elsif input.downcase == 'help'
      puts 'Available commands: ' + available_commands.join(', ')
      true
    else
      false
    end
  end

  def execute_command(command, response)
    case command
    when /^take/
      take_item_from_room(command, response)
    when /^drop/
      drop_item_in_room(command, response)
    when 'inventory'
      response = 'You have: ' + @inventory.join(', ')
    when 'look'
      response = @data['rooms'][@current_state]['description']
    when 'attack'
      # Handle combat logic here
    else
      response = 'uh?'
    end

    puts response
  end

  def take_item_from_room(command, response)
    item = command.split(' ')[1]
    @inventory << item if response.include?("You take the #{item}.")
    @data['rooms'][@current_state]['items'].delete(item)
  end

  def drop_item_in_room(command, _response)
    item = command.split(' ')[1]
    if @inventory.include?(item)
      @inventory.delete(item)
      @data['rooms'][@current_state]['items'] << item
      puts "You drop the #{item}."
    else
      puts "You don't have a #{item} to drop."
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
