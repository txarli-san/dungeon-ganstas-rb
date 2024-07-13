require 'spec_helper'
require_relative '../core/player'

RSpec.describe Player do
  let(:initial_stats) { { 'health' => 12, 'max_health' => 12, 'strength' => 2, 'defense' => 1 } }
  let(:player) { Player.new(initial_stats) }

  describe '#initialize' do
    it 'sets up the player with initial stats' do
      expect(player.stats).to eq(initial_stats)
      expect(player.inventory).to be_an(Inventory)
      expect(player.equipment).to be_an(Equipment)
    end
  end

  describe '#equip' do
    let(:item) { Item.new({ 'name' => 'Sword', 'type' => 'weapon', 'slot' => 'weapon', 'damage' => 5 }) }

    it 'equips an item' do
      player.inventory.add(item)
      player.equip(item)
      expect(player.equipment.slots[:weapon]).to eq(item)
      expect(player.inventory.items).not_to include(item)
      expect(player.stats['strength']).to eq(7) # 2 (base) + 5 (weapon damage)
    end
  end

  describe '#unequip' do
    let(:item) { Item.new({ 'name' => 'Sword', 'type' => 'weapon', 'slot' => 'weapon', 'damage' => 5 }) }

    it 'unequips an item' do
      player.equipment.equip(item)
      player.unequip(:weapon)
      expect(player.equipment.weapon).to be_nil
      expect(player.inventory.items).to include(item)
    end
  end

  describe '#calculate_damage' do
    it 'calculates total damage' do
      player.inventory.add(Item.new({ 'name' => 'Sword', 'type' => 'weapon', 'slot' => 'weapon', 'damage' => 5 }))
      player.equip(player.inventory.items.first)
      expect(player.calculate_damage).to eq(7)  # 2 (base strength) + 5 (weapon damage)
    end
  end

  describe '#calculate_defense' do
    it 'calculates total defense' do
      shield = Item.new({ 'name' => 'Shield', 'type' => 'armor', 'slot' => 'offhand', 'defense' => 3 })
      player.inventory.add(shield)
      player.equip(shield)
      expect(player.calculate_defense).to eq(4) # 1 (base defense) + 3 (shield defense)
    end
  end

  describe '#take_damage' do
    it 'reduces player health' do
      player.take_damage(2)
      expect(player.stats['health']).to eq(10)
    end

    it 'does not reduce health below 0' do
      player.take_damage(15)
      expect(player.stats['health']).to eq(0)
    end
  end

  describe '#display_stats' do
    it 'returns a formatted string of player stats' do
      sword = Item.new({ 'name' => 'Sword', 'type' => 'weapon', 'slot' => 'weapon', 'damage' => 5 })
      player.inventory.add(sword)
      player.equip(sword)
      expected_output = "Health: 12/12\nStrength: 7\nDefense: 1\nWeapon: Sword (Damage: 5)\nTotal Damage: 7"
      expect(player.display_stats).to eq(expected_output)
    end
  end
end
