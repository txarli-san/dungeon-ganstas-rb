require_relative '../core/engine'

RSpec.describe 'Game Integration' do
  let(:engine) { Engine.new('./spec/fixtures/test_data.yml') }

  it 'allows player to take an item, use it, and attack a monster' do
    # Start the game
    initial_description = engine.start
    expect(initial_description).to include('You are in a dark room')

    # Take an item
    take_response = engine.handle_input('take health potion')
    expect(take_response).to include('You take the Health Potion')

    # Use the item
    use_response = engine.handle_input('use health potion')
    expect(use_response).to include('You use the Health Potion and restore')

    # Move to a room with a monster
    move_response = engine.handle_input('go north')
    expect(move_response).to include('You are in a long hallway')
    expect(move_response).to include('goblin stands guard here')

    # Attack the monster
    attack_response = engine.handle_input('attack goblin')
    expect(attack_response).to include('You attack the goblin')
    expect(attack_response).to include('The goblin counterattacks')
  end
end
