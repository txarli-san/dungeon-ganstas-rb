require 'spec_helper'
require_relative '../core/room_manager'

RSpec.describe RoomManager do
  let(:rooms) do
    {
      'start' => {
        'description' => 'You are in a dark room.',
        'items' => { 'sword' => { 'name' => 'Sword' } },
        'monsters' => { 'goblin' => { 'health' => 20 } },
        'transitions' => { 'go north' => 'hallway' }
      },
      'hallway' => {
        'description' => 'You are in a long hallway.',
        'items' => {},
        'transitions' => { 'go south' => 'start' }
      }
    }
  end

  let(:room_manager) { RoomManager.new(rooms) }

  describe '#get_current_description' do
    it 'returns the correct room description with items and monsters' do
      description = room_manager.get_current_description('start')
      expect(description).to include('You are in a dark room.')
      expect(description).to include('Items here: Sword')
      expect(description).to include('Monsters here: goblin')
    end
  end

  describe '#get_next_room' do
    it 'returns the correct next room' do
      expect(room_manager.get_next_room('start', 'north')).to eq('hallway')
    end

    it 'returns nil for invalid direction' do
      expect(room_manager.get_next_room('start', 'south')).to be_nil
    end
  end
end
