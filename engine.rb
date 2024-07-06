require 'yaml'

class TextAdventure
  def initialize(data_file)
    @data = YAML.load_file(data_file)
    @current_state = 'start'
    @inventory = []
  end

  def start
    @current_state = 'start'
    get_current_description
  end

  def handle_input(input)
    if handle_command(input)
      return get_current_description
    end

    next_state = @data[@current_state]['transitions'][input.downcase]
    if next_state
      @current_state = next_state
      get_current_description
    else
      "I don't understand that command."
    end
  end

  def handle_command(input)
    commands = @data[@current_state]['commands'] || {}
    command_response = commands[input.downcase]

    if command_response
      if input.downcase.start_with?('take')
        item = input.downcase.split(' ')[1]
        @inventory << item if command_response.include?("You take the #{item}.")
      elsif input.downcase.start_with?('attack')
        # Handle combat logic here
      end

      puts command_response
      true
    else
      false
    end
  end

  def get_current_description
    state = @data[@current_state]
    description = state['description']
    description += "\nItems here: " + state['items'].join(', ') if state['items'] && state['items'].any?
    description += "\nMonsters here: " + state['monsters'].keys.join(', ') if state['monsters'] && state['monsters'].any?
    description
  end
end
