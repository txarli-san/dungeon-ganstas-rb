class Character
  attr_reader :name, :hp, :inventory

  def initialize(name, hp)
    @name = name
    @hp = hp
    @inventory = []
  end

  def add_item(item)
    @inventory << item
  end

  def remove_item(item)
    @inventory.delete(item)
  end

  def attack(target)
    weapon = @inventory.find { |item| item.type == 'weapon' }
    damage = weapon ? weapon.damage : 1
    target.take_damage(damage)
  end

  def take_damage(amount)
    armor = @inventory.find { |item| item.type == 'armor' }
    damage_reduction = armor ? armor.defense : 0
    @hp -= [amount - damage_reduction, 0].max
    @hp = [@hp, 0].max
  end
end
