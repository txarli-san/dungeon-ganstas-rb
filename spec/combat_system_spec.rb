require 'spec_helper'
require_relative '../core/combat_system'

RSpec.describe CombatSystem do
  let(:game_state) { instance_double('GameState') }
  let(:combat_system) { CombatSystem.new(game_state) }
  let(:current_room) { 'current_room' }

  describe '#attack' do
    before do
      allow(game_state).to receive(:get_room_data).and_return({
                                                                'monsters' => { 'goblin' => { 'health' => 20,
                                                                                              'attack' => 3 } }
                                                              })
      allow(game_state).to receive(:player).and_return({ 'strength' => 5, 'defense' => 2, 'health' => 100 })
    end

    it 'handles combat between player and monster' do
      expect(combat_system.attack('goblin', current_room)).to include('You attack the goblin')
    end

    it 'handles defeating a monster' do
      allow(game_state).to receive(:get_room_data).and_return({
                                                                'monsters' => { 'goblin' => { 'health' => 1,
                                                                                              'attack' => 3 } }
                                                              })

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
