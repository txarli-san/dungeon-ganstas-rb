require 'spec_helper'
require_relative '../lib/character'

RSpec.describe Character do
  let(:character) { Character.new("Test Character", 100) }

  describe '#initialize' do
    it 'sets the name and hp' do
      expect(character.name).to eq("Test Character")
      expect(character.hp).to eq(100)
    end

    it 'initializes an empty inventory' do
      expect(character.inventory).to be_empty
    end
  end

  describe '#add_item' do
    let(:item) { double('Item') }

    it 'adds an item to the inventory' do
      character.add_item(item)
      expect(character.inventory).to include(item)
    end
  end

  describe '#remove_item' do
    let(:item) { double('Item') }

    it 'removes an item from the inventory' do
      character.add_item(item)
      character.remove_item(item)
      expect(character.inventory).not_to include(item)
    end
  end

  describe '#attack' do
    let(:target) { double('Target') }
    let(:weapon) { double('Weapon', type: 'weapon', damage: 10) }

    it 'deals damage based on weapon' do
      character.add_item(weapon)
      expect(target).to receive(:take_damage).with(10)
      character.attack(target)
    end

    it 'deals 1 damage if no weapon' do
      expect(target).to receive(:take_damage).with(1)
      character.attack(target)
    end
  end

  describe '#take_damage' do
    let(:armor) { double('Armor', type: 'armor', defense: 5) }

    it 'reduces hp by damage amount' do
      expect { character.take_damage(10) }.to change { character.hp }.by(-10)
    end

    it 'reduces damage based on armor' do
      character.add_item(armor)
      expect { character.take_damage(10) }.to change { character.hp }.by(-5)
    end

    it 'does not reduce hp below 0' do
      character.take_damage(150)
      expect(character.hp).to eq(0)
    end
  end
end
