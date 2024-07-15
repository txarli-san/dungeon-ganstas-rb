class Equipment
  attr_reader :slots

  SLOT_TYPES = %i[weapon head chest shield]

  def initialize
    @slots = Hash.new(nil)
  end

  def can_equip?(item)
    SLOT_TYPES.include?(item.slot) && @slots[item.slot].nil?
  end

  def equip(item)
    old_item = @slots[item.slot]
    @slots[item.slot] = item
    old_item
  end

  def unequip(slot)
    item = @slots[slot]
    @slots[slot] = nil
    item
  end

  def weapon
    @slots[:weapon]
  end

  def shield
    @slots[:shield]
  end

  def chest
    @slots[:chest]
  end

  def total_defense
    %i[head chest shield].sum { |slot| @slots[slot]&.defense || 0 }
  end

  def total_attack
    weapon ? weapon.damage : 0
  end
end
