class Character
  ABILITIES = %i[strength dexterity constitution intelligence wisdom charisma]

  attr_reader :abilities

  def initialize
    @abilities = generate_abilities
  end

  private

  def generate_abilities
    ABILITIES.each_with_object({}) do |ability, hash|
      hash[ability] = roll_ability
    end
  end

  def roll_ability
    3.times.map { rand(1..6) }.sum
  end
end
