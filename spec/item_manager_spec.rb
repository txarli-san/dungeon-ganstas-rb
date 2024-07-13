require 'spec_helper'
require_relative '../managers/item_manager'

RSpec.describe ItemManager do
  let(:items) do
    {
      'sword' => { 'name' => 'Sword', 'type' => 'weapon', 'damage' => 5 },
      'health_potion' => { 'name' => 'Health Potion', 'type' => 'consumable', 'effect' => { 'health' => 20 } }
    }
  end

  let(:game_state) { instance_double('GameState') }
  let(:player) { instance_double('Player') }
  let(:inventory) { instance_double('Inventory') }
  let(:item_manager) { ItemManager.new(items) }

  before do
    allow(game_state).to receive(:player).and_return(player)
    allow(player).to receive(:inventory).and_return(inventory)
    allow(game_state).to receive(:current_room).and_return('current_room')
  end

  describe '#take_item' do
    it 'allows taking an item from the room' do
      allow(game_state).to receive(:get_room_data).and_return({ 'items' => { 'sword' => items['sword'] } })
      allow(inventory).to receive(:add)

      expect(item_manager.take_item('sword', game_state)).to include('You take the Sword')
    end
  end

  describe '#drop_item' do
    it 'allows dropping an item in the room' do
      allow(inventory).to receive(:items).and_return([Item.new(items['sword'])])
      allow(inventory).to receive(:remove)
      allow(game_state).to receive(:get_room_data).and_return({ 'items' => {} })

      expect(item_manager.drop_item('Sword', game_state)).to include('You drop the Sword')
    end
  end

  describe '#use_item' do
    context 'when using a consumable' do
      it 'applies the item effect' do
        allow(inventory).to receive(:items).and_return([Item.new(items['health_potion'])])
        allow(player).to receive(:stats).and_return({ 'health' => 80, 'max_health' => 100 })
        allow(player).to receive(:inventory).and_return(inventory)
        allow(inventory).to receive(:remove)

        expect(item_manager.use_item('Health Potion', game_state)).to include('restore 20 health')
      end
    end
  end
end
