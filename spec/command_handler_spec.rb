require 'spec_helper'
require_relative '../core/command_handler'

RSpec.describe CommandHandler do
  let(:game_state) { instance_double('GameState') }
  let(:room_manager) { instance_double('RoomManager') }
  let(:item_manager) { instance_double('ItemManager') }
  let(:combat_system) { instance_double('CombatSystem') }
  let(:command_handler) { CommandHandler.new(game_state, room_manager, item_manager, combat_system) }

  describe '#handle' do
    context 'when given a movement command' do
      it 'calls handle_movement' do
        allow(game_state).to receive(:current_room).and_return('start')
        allow(room_manager).to receive(:get_next_room).with('start', 'north').and_return('new_room')
        allow(game_state).to receive(:change_room)
        allow(room_manager).to receive(:get_current_description).with('new_room').and_return('New room description')

        expect(command_handler.handle('go north')).to eq('New room description')
      end
    end

    context 'when given an item-related command' do
      it 'calls the appropriate item_manager method' do
        allow(item_manager).to receive(:take_item).and_return('You take the item')
        expect(command_handler.handle('take sword')).to eq('You take the item')
      end
    end

    context 'when given an attack command' do
      it 'calls the combat_system' do
        allow(combat_system).to receive(:attack).and_return('You attack the monster')
        expect(command_handler.handle('attack goblin')).to eq('You attack the monster')
      end
    end

    context 'when given an invalid command' do
      it 'returns an error message' do
        expect(command_handler.handle('invalid command')).to eq("I don't understand that command.")
      end
    end
  end
end
