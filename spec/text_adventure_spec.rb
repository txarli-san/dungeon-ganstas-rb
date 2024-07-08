require 'yaml'
require_relative '../engine'

RSpec.describe TextAdventure do
  let(:data_file) { 'spec/fixtures/test_data.yml' }
  let(:game) { TextAdventure.new(data_file) }

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
                                                        'description' => 'You are in a dark room. There is a door to the north and a small table with a lamp.',
                                                        'items' => ['lamp'],
                                                        'commands' => {
                                                          'look' => 'You see a door to the north and a small table with a lamp.',
                                                          'take lamp' => 'You take the lamp.'
                                                        },
                                                        'transitions' => {
                                                          'go north' => 'hallway'
                                                        }
                                                      },
                                                      'hallway' => {
                                                        'description' => 'You are in a long hallway. There are doors to the north and south. A goblin stands guard here.',
                                                        'items' => ['health_potion'],
                                                        'monsters' => {
                                                          'goblin' => {
                                                            'health' => 30,
                                                            'attack' => 5,
                                                            'defense' => 2
                                                          }
                                                        },
                                                        'commands' => {
                                                          'look' => 'You see doors to the north and south. A goblin is here.',
                                                          'attack goblin' => 'You attack the goblin!'
                                                        },
                                                        'transitions' => {
                                                          'go south' => 'start',
                                                          'go north' => 'library'
                                                        }
                                                      },
                                                      'library' => {
                                                        'description' => 'You are in a dusty library.',
                                                        'items' => %w[book sword],
                                                        'transitions' => {
                                                          'go south' => 'hallway'
                                                        }
                                                      }
                                                    },
                                                    'items' => {
                                                      'health_potion' => {
                                                        'type' => 'consumable',
                                                        'effect' => { 'health' => 20 }
                                                      },
                                                      'sword' => {
                                                        'type' => 'weapon',
                                                        'damage' => 5
                                                      },
                                                      'shield' => {
                                                        'type' => 'armor',
                                                        'defense' => 3
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
      game.take_item_from_room('take lamp', 'You take the lamp.')
      expect(game.instance_variable_get(:@inventory)).to include('lamp')
      expect(game.instance_variable_get(:@data)['rooms']['start']['items']).not_to include('lamp')
    end

    it 'does not add non-existent items to inventory' do
      game.instance_variable_set(:@current_state, 'start')
      game.take_item_from_room('take axe', 'You take the axe.')
      expect(game.instance_variable_get(:@inventory)).not_to include('axe')
    end
  end

  describe '#drop_item_in_room' do
    before do
      game.instance_variable_set(:@inventory, ['lamp'])
    end

    it 'drops an item from inventory to the current room' do
      game.instance_variable_set(:@current_state, 'hallway')
      expect(game.drop_item_in_room('drop lamp', '')).to eq('You drop the lamp.')
      expect(game.instance_variable_get(:@inventory)).not_to include('lamp')
      expect(game.instance_variable_get(:@data)['rooms']['hallway']['items']).to include('lamp')
    end

    it 'handles dropping items in rooms with no items' do
      game.instance_variable_set(:@current_state, 'library')
      game.instance_variable_get(:@data)['rooms']['library'].delete('items')
      expect(game.drop_item_in_room('drop lamp', '')).to eq('You drop the lamp.')
      expect(game.instance_variable_get(:@inventory)).not_to include('lamp')
      expect(game.instance_variable_get(:@data)['rooms']['library']['items']).to eq(['lamp'])
    end

    it 'does not drop items not in inventory' do
      expect(game.drop_item_in_room('drop sword', '')).to eq("You don't have a sword to drop.")
    end
  end

  describe '#use_item' do
    before do
      game.instance_variable_set(:@inventory, %w[health_potion sword shield])
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
      expect { game.handle_input('inventory') }.to output(/You have:/).to_stdout
    end

    it 'executes room-specific commands' do
      game.instance_variable_set(:@current_state, 'start')
      expect { game.handle_input('take lamp') }.to output(/You take the lamp/).to_stdout
    end

    it 'handles invalid commands' do
      expect { game.handle_input('dance') }.to output(/I don't understand that command/).to_stdout
    end

    it 'handles dropping items in any room' do
      game.instance_variable_set(:@current_state, 'start')
      game.instance_variable_set(:@inventory, ['lamp'])
      expect { game.handle_input('drop lamp') }.to output("You drop the lamp.\n").to_stdout
      expect(game.instance_variable_get(:@inventory)).not_to include('lamp')
      expect(game.instance_variable_get(:@data)['rooms']['start']['items']).to include('lamp')

      game.handle_input('go north')
      game.instance_variable_set(:@inventory, ['health_potion'])
      expect { game.handle_input('drop health_potion') }.to output("You drop the health_potion.\n").to_stdout
      expect(game.instance_variable_get(:@inventory)).not_to include('health_potion')
      expect(game.instance_variable_get(:@data)['rooms']['hallway']['items']).to include('health_potion')
    end
  end

  describe '#show_inventory' do
    it 'displays the contents of the inventory' do
      game.instance_variable_set(:@inventory, %w[lamp sword])
      expect(game.show_inventory).to eq('You have: lamp, sword')
    end

    it 'displays an empty inventory message when inventory is empty' do
      game.instance_variable_set(:@inventory, [])
      expect(game.show_inventory).to eq('You have: ')
    end
  end

  describe '#get_current_description' do
    it 'includes room description, items, monsters, and available commands' do
      game.instance_variable_set(:@current_state, 'hallway')
      description = game.get_current_description
      expect(description).to include('You are in a long hallway')
      expect(description).to include('Items here: health_potion')
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
