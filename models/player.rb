require_relative 'inventory'
require_relative 'equipment'

class Player
  attr_reader :stats, :inventory, :equipment

  def initialize(initial_stats)
    @stats = initial_stats
    @base_attack = initial_stats['attack']
    @inventory = Inventory.new
    @equipment = Equipment.new
  end

  def display_stats
    equipped_weapon = @equipment.weapon
    weapon_damage = equipped_weapon ? equipped_weapon.damage : 0

    [
      "Health: #{@stats['health']}/#{@stats['max_health']}",
      "Attack: #{@stats['attack']}",
      "Defense: #{calculate_defense}",
      "Weapon: #{equipped_weapon ? "#{equipped_weapon.name} (Damage: #{weapon_damage})" : 'None'}",
      "Total Damage: #{calculate_damage}"
    ].join("\n")
  end

  def equip(item)
    return unless @equipment.can_equip?(item)

    @inventory.remove(item)
    old_item = @equipment.equip(item)
    @inventory.add(old_item) if old_item
    update_stats
    "You equip the #{item.name}."
  end

  def unequip(slot)
    item = @equipment.unequip(slot)
    return unless item

    @inventory.add(item)
    update_stats
  end

  def calculate_damage
    @base_attack + (@equipment.weapon ? @equipment.weapon.damage : 0)
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
    @stats['attack'] = @base_attack + @equipment.total_attack
  end
end
