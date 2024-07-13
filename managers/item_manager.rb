require_relative '../models/item'

class ItemManager
  def initialize(items)
    @items = items
  end

  def create_item(item_data)
    Item.new(item_data)
  end

  def take_item(item_name, game_state)
    room_items = game_state.get_room_data(game_state.current_room)['items']
    return "There's no #{item_name} here to take." if room_items.nil? || room_items.empty?

    item_key = room_items.keys.find { |k| k.downcase.gsub('_', ' ') == item_name.downcase }

    if item_key
      item_data = room_items[item_key]
      item = create_item(item_data)
      game_state.player.inventory.add(item)
      room_items.delete(item_key)
      "You take the #{item.name}."
    else
      "There's no #{item_name} here to take."
    end
  end

  def drop_item(item_name, game_state)
    item = game_state.player.inventory.items.find { |i| i.name.downcase == item_name.downcase }
    if item
      game_state.player.inventory.remove(item)
      room_items = game_state.get_room_data(game_state.current_room)['items'] ||= {}
      room_items[item.name.downcase.gsub(' ', '_')] = item.to_h
      "You drop the #{item.name}."
    else
      "You don't have a #{item_name} to drop."
    end
  end

  def use_item(item_name, game_state)
    item = game_state.player.inventory.items.find { |i| i.name.downcase == item_name.downcase }
    return "You don't have a #{item_name} in your inventory." unless item

    case item.type
    when 'consumable'
      use_consumable(item, game_state.player)
    when 'weapon', 'armor'
      equip_item(item, game_state.player)
    else
      "You can't use the #{item_name}."
    end
  end

  private

  def use_consumable(item, player)
    if item.effect['health']
      player.stats['health'] += item.effect['health']
      player.stats['health'] = [player.stats['health'], player.stats['max_health']].min
      player.inventory.remove(item)
      "You use the #{item.name} and restore #{item.effect['health']} health."
    else
      'This item has no effect.'
    end
  end

  def equip_item(item, player)
    player.equip(item)
    "You equip the #{item.name}."
  end
end
