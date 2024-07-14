class Item
  attr_reader :name, :type, :slot, :damage, :defense, :attack_bonus, :effect

  def initialize(data)
    @name = data['name']
    @type = data['type']
    @slot = data['slot']&.to_sym
    @damage = data['damage'] || 0
    @defense = data['defense'] || 0
    @attack_bonus = data['attack_bonus'] || 0
    @effect = data['effect'] || {}
  end

  def to_h
    {
      'name' => @name,
      'type' => @type,
      'slot' => @slot,
      'damage' => @damage,
      'defense' => @defense,
      'attack_bonus' => @attack_bonus,
      'effect' => @effect
    }
  end
end
