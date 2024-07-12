require 'spec_helper'
require_relative '../core/game_state'

RSpec.describe GameState do
  let(:test_data) do
    {
      'player' => { 'health' => 100, 'max_health' => 100, 'strength' => 10, 'defense' => 5 },
      'rooms' => {
        'start' => {
          'description' => 'Test room',
          'items' => { 'sword' => { 'name' => 'Sword', 'type' => 'weapon' } }
        }
      }
    }
  end

  let(:game_state) { GameState.new(test_data) }

  describe '#initialize' do
    it 'sets up the initial game state correctly' do
      expect(game_state.player).to eq(test_data['player'])
      expect(game_state.inventory).to be_empty
      expect(game_state.current_room).to eq('start')
    end
  end

  describe '#add_to_inventory' do
    it 'adds an item to the inventory' do
      game_state.add_to_inventory('Sword')
      expect(game_state.inventory).to include('Sword')
    end
  end

  describe '#remove_from_inventory' do
    it 'removes an item from the inventory' do
      game_state.add_to_inventory('Sword')
      game_state.remove_from_inventory('Sword')
      expect(game_state.inventory).not_to include('Sword')
    end
  end

  describe '#get_room_data' do
    it 'returns the correct room data' do
      expect(game_state.get_room_data('start')).to eq(test_data['rooms']['start'])
    end
  end
end
