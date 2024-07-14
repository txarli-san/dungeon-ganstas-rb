class Inventory
  attr_reader :items

  def initialize
    @items = []
  end

  def add(item)
    @items << item
  end

  def remove(item)
    @items.delete_if { |i| i.name == item.name }
  end
end
