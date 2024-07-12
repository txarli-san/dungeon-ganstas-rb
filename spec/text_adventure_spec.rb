require 'yaml'
require_relative '../engine'

RSpec.describe Engine do
  let(:data_file) { 'data/game_data.yml' }
  let(:game) { Engine.new(data_file) }

  before do
    allow(YAML).to receive(:load_file).and_return({
                                                    'player' => {
                                                      'health' => 100,
                                                      'max_health' => 100,
                                                      'strength' => 10,
                                                      'defense' => 5
                                                    },
                                                    'rooms' => {
                                                      'start' => {
                                                        'description' => 'You are in a dark room. There is a door to the north.',
                                                        'items' => {
                                                          'iron_sword' => {
                                                            'name' => 'Iron Sword',
                                                            'type' => 'weapon',
                                                            'damage' => 6,
                                                            'abilities' => %w[slash thrust]
                                                          }
                                                        },
                                                        'commands' => {
                                                          'take iron sword' => 'You take the Iron Sword.'
                                                        },
                                                        'transitions' => {
                                                          'go north' => 'hallway'
                                                        }
                                                      },
                                                      'hallway' => {
                                                        'description' => 'You are in a long hallway. There are doors to the north and south. A goblin stands guard here.',
                                                        'items' => {},
                                                        'monsters' => {
                                                          'goblin' => {
                                                            'health' => 30,
                                                            'attack' => 5
                                                          }
                                                        },
                                                        'commands' => {
                                                          'attack goblin' => 'You attack the goblin!',
                                                          'talk to goblin' => 'The goblin looks suspiciously at you but says nothing.'
                                                        },
                                                        'transitions' => {
                                                          'go north' => 'library',
                                                          'go south' => 'start'
                                                        }
                                                      }
                                                    },
                                                    'global_commands' => {
                                                      'inventory' => 'Check your inventory.',
                                                      'help' => 'Show available commands.'
                                                    }
                                                  })
  end

  describe '#take_item_from_room' do
    it 'adds the item to inventory and removes it from the room' do
      game.instance_variable_set(:@current_state, 'start')
      game.take_item_from_room('take iron sword', '')
      expect(game.instance_variable_get(:@inventory)).to include(hash_including('name' => 'Iron Sword'))
      expect(game.instance_variable_get(:@data)['rooms']['start']['items']).not_to have_key('iron_sword')
    end

    it 'does not add non-existent items to inventory' do
      game.instance_variable_set(:@current_state, 'start')
      game.take_item_from_room('take axe', '')
      expect(game.instance_variable_get(:@inventory)).to be_empty
    end
  end

  describe '#drop_item_in_room' do
    before do
      game.instance_variable_set(:@inventory, [{ 'name' => 'Iron Sword', 'type' => 'weapon', 'damage' => 6 }])
    end

    it 'drops an item from inventory to the current room' do
      game.instance_variable_set(:@current_state, 'hallway')
      expect(game.drop_item_in_room('drop iron sword', '')).to eq('You drop the Iron Sword.')
      expect(game.instance_variable_get(:@inventory)).to be_empty
      expect(game.instance_variable_get(:@data)['rooms']['hallway']['items']).to have_key('iron_sword')
    end

    it 'does not drop items not in inventory' do
      expect(game.drop_item_in_room('drop axe', '')).to eq("You don't have a axe to drop.")
    end
  end

  describe '#use_item' do
    before do
      game.instance_variable_set(:@inventory, %w[health_potion sword shield])
      game.instance_variable_set(:@items, {
                                   'health_potion' => { 'type' => 'consumable', 'effect' => { 'health' => 20 } },
                                   'sword' => { 'type' => 'weapon', 'damage' => 5 },
                                   'shield' => { 'type' => 'armor', 'defense' => 3 }
                                 })
    end

    it 'uses a consumable item and removes it from inventory' do
      game.instance_variable_get(:@player)['health'] = 80
      expect(game.use_item('health_potion')).to include('restore 20 health')
      expect(game.instance_variable_get(:@player)['health']).to eq(100)
      expect(game.instance_variable_get(:@inventory)).not_to include('health_potion')
    end

    it 'equips a weapon and updates player stats' do
      expect(game.use_item('sword')).to include('Your strength is now 15')
      expect(game.instance_variable_get(:@player)['strength']).to eq(15)
    end

    it 'equips armor and updates player stats' do
      expect(game.use_item('shield')).to include('Your defense is now 8')
      expect(game.instance_variable_get(:@player)['defense']).to eq(8)
    end

    it 'returns an error for non-existent items' do
      expect(game.use_item('magic_wand')).to eq("You don't have a magic_wand in your inventory.")
    end
  end

  describe '#handle_input' do
    it 'moves to a new room when given a valid direction' do
      game.instance_variable_set(:@current_state, 'start')
      game.handle_input('go north')
      expect(game.instance_variable_get(:@current_state)).to eq('hallway')
    end

    it 'does not move when given an invalid direction' do
      game.instance_variable_set(:@current_state, 'start')
      game.handle_input('go west')
      expect(game.instance_variable_get(:@current_state)).to eq('start')
    end

    it 'executes global commands' do
      expect { game.handle_input('inventory') }.to output(/Your inventory is empty/).to_stdout
    end

    it 'executes room-specific commands' do
      game.instance_variable_set(:@current_state, 'start')
      expect { game.handle_input('take iron sword') }.to output(/You take the Iron Sword/).to_stdout
    end

    it 'handles invalid commands' do
      expect { game.handle_input('dance') }.to output(/I don't understand that command/).to_stdout
    end
  end

  describe '#show_inventory' do
    it 'displays the contents of the inventory' do
      game.instance_variable_set(:@inventory, %w[lamp sword])
      expect(game.show_inventory).to eq('You have: lamp, sword')
    end

    it 'displays an empty inventory message when inventory is empty' do
      game.instance_variable_set(:@inventory, [])
      expect(game.show_inventory).to eq('Your inventory is empty.')
    end
  end

  describe '#get_current_description' do
    it 'includes room description, items, monsters, and available commands' do
      game.instance_variable_set(:@current_state, 'hallway')
      description = game.get_current_description
      expect(description).to include('You are in a long hallway')
      expect(description).to include('Monsters here: goblin')
      expect(description).to include('Available commands:')
    end
  end

  describe 'player stats' do
    it 'initializes player stats correctly' do
      player = game.instance_variable_get(:@player)
      expect(player['health']).to eq(100)
      expect(player['max_health']).to eq(100)
      expect(player['strength']).to eq(10)
      expect(player['defense']).to eq(5)
    end

    it 'updates player health after combat' do
      game.instance_variable_set(:@current_state, 'hallway')
      game.attack('goblin')
      player = game.instance_variable_get(:@player)
      expect(player['health']).to be < 100
    end

    it 'checks for game over condition' do
      game.instance_variable_set(:@current_state, 'hallway')
      game.instance_variable_get(:@player)['health'] = 1
      expect(game.attack('goblin')).to include('Game over')
    end
  end
end
