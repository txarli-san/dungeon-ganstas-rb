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
                                                        'items' => [],
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
                                                      }
                                                    },
                                                    'global_commands' => {
                                                      'inventory' => 'Check your inventory.',
                                                      'help' => 'Show available commands.'
                                                    }
                                                  })
  end

  describe '#start' do
    it 'starts the game and shows the initial description' do
      expect(game.start).to include('You are in a dark room.')
    end
  end

  describe '#handle_input' do
    context 'with valid command' do
      it 'executes the command and updates the game state' do
        game.start
        game.handle_input('take lamp')
        expect(game.instance_variable_get(:@inventory)).to include('lamp')
      end
    end

    context 'with invalid command' do
      it 'returns an error message' do
        game.start
        expect { game.handle_input('fly') }.to output("I don't understand that command.\n").to_stdout
      end
    end

    context 'with movement command' do
      it 'changes the current state' do
        game.start
        game.handle_input('go north')
        expect(game.instance_variable_get(:@current_state)).to eq('hallway')
      end
    end
  end

  describe '#available_commands' do
    it 'lists all available commands in the current room' do
      game.start
      expect(game.available_commands).to include('look', 'take lamp', 'inventory', 'help')
    end
  end

  describe '#attack' do
    before do
      game.instance_variable_set(:@current_state, 'hallway')
    end

    it 'attacks a monster and updates its health' do
      expect(game.attack('goblin')).to include('You attack the goblin for 8 damage!')
      monster = game.instance_variable_get(:@data)['rooms']['hallway']['monsters']['goblin']
      expect(monster['health']).to eq(22)
    end

    it 'removes the monster when its health reaches 0' do
      4.times { game.attack('goblin') }
      monsters = game.instance_variable_get(:@data)['rooms']['hallway']['monsters']
      expect(monsters).not_to have_key('goblin')
    end

    it 'returns an error message when the target does not exist' do
      expect(game.attack('dragon')).to eq("There's no dragon here to attack.")
    end
  end
end
