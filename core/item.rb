class Item
  attr_reader :name, :type, :slot, :damage, :defense, :strength_bonus, :effect

  def initialize(data)
    @name = data['name']
    @type = data['type']
    @slot = data['slot']&.to_sym
    @damage = data['damage'] || 0
    @defense = data['defense'] || 0
    @strength_bonus = data['strength_bonus'] || 0
    @effect = data['effect'] || {}
  end

  def to_h
    {
      'name' => @name,
      'type' => @type,
      'slot' => @slot,
      'damage' => @damage,
      'defense' => @defense,
      'strength_bonus' => @strength_bonus,
      'effect' => @effect
    }
  end
end
