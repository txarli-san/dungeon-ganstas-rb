RSpec.describe GameState do
  let(:test_data) do
    {
      'player' => { 'health' => 100, 'max_health' => 100, 'attack' => 10, 'defense' => 5 },
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
      expect(game_state.player).to be_a(Player)
      expect(game_state.player.stats).to eq(test_data['player'].transform_keys(&:to_s))
      expect(game_state.current_room).to eq('start')
    end
  end

  describe '#get_room_data' do
    it 'returns the correct room data' do
      expect(game_state.get_room_data('start')).to eq(test_data['rooms']['start'])
    end
  end

  describe '#inventory' do
    it 'returns the player\'s inventory' do
      expect(game_state.inventory).to be_an(Inventory)
      expect(game_state.inventory.items).to be_empty
    end
  end
end
