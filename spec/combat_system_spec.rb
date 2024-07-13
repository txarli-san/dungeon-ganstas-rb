require 'spec_helper'
require_relative '../core/combat_system'

RSpec.describe CombatSystem do
  let(:game_state) { instance_double('GameState') }
  let(:player) { instance_double('Player') }
  let(:combat_system) { CombatSystem.new(game_state) }
  let(:current_room) { 'current_room' }

  before do
    allow(game_state).to receive(:player).and_return(player)
    allow(player).to receive(:calculate_damage).and_return(10)
    allow(player).to receive(:calculate_defense).and_return(5)
    allow(player).to receive(:stats).and_return({ health: 100 })
    allow(game_state).to receive(:get_room_data).and_return({
                                                              'monsters' => { 'goblin' => { 'health' => 20,
                                                                                            'attack' => 3, 'defense' => 1 } }
                                                            })
  end

  describe '#attack' do
    it 'handles combat between player and monster' do
      expect(combat_system.attack('goblin', current_room)).to include('You attack the goblin')
    end

    it 'handles defeating a monster' do
      allow(player).to receive(:calculate_damage).and_return(30)
      expect(combat_system.attack('goblin', current_room)).to include('The goblin is defeated!')
    end

    it 'returns an error message when there are no monsters' do
      allow(game_state).to receive(:get_room_data).and_return({ 'monsters' => {} })

      expect(combat_system.attack('goblin', current_room)).to eq('There are no monsters here to attack.')
    end

    it 'returns an error message when the specified monster is not present' do
      expect(combat_system.attack('dragon', current_room)).to eq("There's no dragon here to attack.")
    end
  end
end
