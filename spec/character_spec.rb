require 'spec_helper'
require_relative '../lib/character'

RSpec.describe Character do
  let(:character) { Character.new }

  describe '#initialize' do
    it 'generates abilities' do
      expect(character.abilities.keys).to match_array(Character::ABILITIES)
    end

    it 'generates ability scores between 3 and 18' do
      character.abilities.values.each do |score|
        expect(score).to be_between(3, 18)
      end
    end
  end

  describe '#roll_ability' do
    it 'returns a number between 3 and 18' do
      100.times do
        ability_score = character.send(:roll_ability)
        expect(ability_score).to be_between(3, 18)
      end
    end

    it 'provides a relatively even distribution' do
      rolls = 10_000.times.map { character.send(:roll_ability) }
      average = rolls.sum.to_f / rolls.size
      expect(average).to be_within(0.5).of(10.5) # 10.5 is the expected average for 3d6
    end
  end
end
