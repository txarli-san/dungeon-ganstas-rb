require_relative 'inventory'
require_relative 'equipment'

class Player
  attr_reader :stats, :inventory, :equipment

  def initialize(initial_stats)
    @stats = initial_stats
    @inventory = Inventory.new
    @equipment = Equipment.new
  end

  def equip(item)
    return unless @equipment.can_equip?(item)

    @inventory.remove(item)
    @equipment.equip(item)
    update_stats
  end

  def unequip(slot)
    item = @equipment.unequip(slot)
    return unless item

    @inventory.add(item)
    update_stats
  end

  def calculate_damage
    @stats['strength'].to_i + (@equipment.weapon ? @equipment.weapon.damage : 0)
  end

  def calculate_defense
    @stats['defense'].to_i + @equipment.total_defense
  end

  def take_damage(amount)
    @stats['health'] -= amount
    @stats['health'] = 0 if @stats['health'] < 0
  end

  private

  def update_stats
    @stats['strength'] = @stats['strength'] + @equipment.total_strength
    @stats['defense'] = @stats['defense'] + @equipment.total_defense
  end
end
