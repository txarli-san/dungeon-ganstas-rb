# frozen_string_literal: true

require 'yaml'

require_relative 'game_state'
require_relative 'command_handler'
require_relative 'combat_system'
require_relative 'world'
require_relative '../managers/room_manager'
require_relative '../managers/item_manager'
require_relative '../utils/output_formatter'

class Engine
  attr_reader :game_state, :command_handler, :room_manager, :item_manager, :combat_system, :output_formatter

  def initialize(data_file)
    @data = World.generate(YAML.load_file(data_file))
    @game_state = GameState.new(@data)
    @room_manager = RoomManager.new(@data['rooms'])
    @item_manager = ItemManager.new(@data['items'])
    @combat_system = CombatSystem.new(@game_state)
    @output_formatter = OutputFormatter.new
    @command_handler = CommandHandler.new(@game_state, @room_manager, @item_manager, @combat_system)
  end

  def start
    @output_formatter.format_description(@room_manager.get_current_description(@game_state.current_room))
  end

  def handle_input(input)
    result = @command_handler.handle(input)
    @output_formatter.format_result(result)
  end
end
