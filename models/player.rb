require_relative 'inventory'
require_relative 'equipment'

class Player
  attr_reader :stats, :inventory, :equipment

  def initialize(initial_stats)
    @stats = initial_stats
    @base_attack = initial_stats['attack']
    @base_defense = initial_stats['defense']
    @inventory = Inventory.new
    @equipment = Equipment.new
  end

  def display_stats
    equipped_weapon = @equipment.weapon
    weapon_damage = equipped_weapon ? equipped_weapon.damage : 0
    equipped_shield = @equipment.shield
    shield_defense = equipped_shield ? equipped_shield.defense : 0
    equipped_chest = @equipment.chest
    chest_defense = equipped_chest ? equipped_chest.defense : 0

    [
      "Health: #{@stats['health']}/#{@stats['max_health']}",
      "Attack: #{calculate_damage}",
      "Defense: #{calculate_defense}",
      "Weapon: #{equipped_weapon ? "#{equipped_weapon.name} (Damage: #{weapon_damage})" : 'None'}",
      "Shield: #{equipped_shield ? "#{equipped_shield.name} (Defense: #{shield_defense})" : 'None'}",
      "Armor: #{equipped_chest ? "#{equipped_chest.name} (Defense: #{chest_defense})" : 'None'}"
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
    @base_defense + (@equipment.total_defense || 0)
  end

  def take_damage(amount)
    @stats['health'] -= amount
    @stats['health'] = 0 if @stats['health'] < 0
  end

  private

  def update_stats
    @stats['attack'] = @base_attack + @equipment.total_attack
    @stats['defense'] = @base_defense + @equipment.total_defense
  end
end
