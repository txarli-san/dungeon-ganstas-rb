require_relative 'inventory'
require_relative 'equipment'

class Player
  attr_reader :stats, :inventory, :equipment

  def initialize(initial_stats)
    @stats = initial_stats
    @base_strength = initial_stats['strength']
    @inventory = Inventory.new
    @equipment = Equipment.new
  end

  def display_stats
    equipped_weapon = @equipment.weapon
    weapon_damage = equipped_weapon ? equipped_weapon.damage : 0

    stats = {
      "Health": "#{@stats['health']}/#{@stats['max_health']}",
      "Strength": @stats['strength'],
      "Defense": calculate_defense,
      "Weapon": equipped_weapon ? "#{equipped_weapon.name} (Damage: #{weapon_damage})" : 'None',
      "Total Damage": calculate_damage
    }

    stats.map { |key, value| "#{key.to_s.ljust(15)}: #{value}" }.join("\n")
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
    @base_strength + (@equipment.weapon ? @equipment.weapon.damage : 0)
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
    @stats['strength'] = @base_strength + @equipment.total_strength
  end
end
