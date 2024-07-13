require 'spec_helper'
require_relative '../core/item_manager'

RSpec.describe ItemManager do
  let(:items) do
    {
      'sword' => { 'name' => 'Sword', 'type' => 'weapon', 'damage' => 5 },
      'health_potion' => { 'name' => 'Health Potion', 'type' => 'consumable', 'effect' => { 'health' => 20 } }
    }
  end

  let(:game_state) { instance_double('GameState') }
  let(:item_manager) { ItemManager.new(items) }

  before do
    allow(game_state).to receive(:current_room).and_return('current_room')
  end

  describe '#take_item' do
    it 'allows taking an item from the room' do
      allow(game_state).to receive(:get_room_data).and_return({ 'items' => { 'sword' => items['sword'] } })
      allow(game_state).to receive(:add_to_inventory)

      expect(item_manager.take_item('sword', game_state)).to include('You take the Sword')
    end
  end

  describe '#drop_item' do
    it 'allows dropping an item in the room' do
      allow(game_state).to receive(:inventory).and_return([{ 'name' => 'Sword' }])
      allow(game_state).to receive(:remove_from_inventory)
      allow(game_state).to receive(:get_room_data).and_return({ 'items' => {} })

      expect(item_manager.drop_item('Sword', game_state)).to include('You drop the Sword')
    end
  end

  describe '#use_item' do
    context 'when using a consumable' do
      it 'applies the item effect' do
        allow(game_state).to receive(:inventory).and_return([{ 'name' => 'Health Potion' }])
        allow(game_state).to receive(:player).and_return({ 'health' => 80, 'max_health' => 100 })
        allow(game_state).to receive(:remove_from_inventory)

        expect(item_manager.use_item('Health Potion', game_state)).to include('restore 20 health')
      end
    end
  end
end
