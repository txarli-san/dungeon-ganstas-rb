class Equipment
  attr_reader :slots

  SLOT_TYPES = %i[weapon head chest]

  def initialize
    @slots = Hash.new(nil)
  end

  def can_equip?(item)
    SLOT_TYPES.include?(item.slot) && @slots[item.slot].nil?
  end

  def equip(item)
    @slots[item.slot] = item if can_equip?(item)
  end

  def unequip(slot)
    item = @slots[slot]
    @slots[slot] = nil
    item
  end

  def weapon
    @slots['weapon']
  end

  def total_defense
    %i[head chest].sum { |slot| @slots[slot]&.defense || 0 }
  end

  def total_strength
    @slots.values.compact.sum(&:damage)
  end
end
