class ItemManager
  def initialize(items)
    @items = items
  end

  def take_item(item_name, game_state)
    room_items = game_state.get_room_data(game_state.current_room)['items']
    return "There's no #{item_name} here to take." if room_items.nil? || room_items.empty?

    item_key = room_items.keys.find { |k| k.gsub('_', ' ').downcase == item_name.downcase }

    if item_key
      item = room_items[item_key]
      game_state.add_to_inventory(item.is_a?(Hash) ? item : { 'name' => item_key.gsub('_', ' ').capitalize })
      room_items.delete(item_key)
      "You take the #{item.is_a?(Hash) ? item['name'] : item_key.gsub('_', ' ').capitalize}."
    else
      "There's no #{item_name} here to take."
    end
  end

  def drop_item(item_name, game_state)
    item = game_state.inventory.find do |i|
      i.is_a?(Hash) ? i['name'].downcase == item_name.downcase : i.downcase == item_name.downcase
    end
    if item
      game_state.remove_from_inventory(item)
      room_items = game_state.get_room_data(game_state.current_room)['items'] ||= {}
      item_key = item.is_a?(Hash) ? item['name'].downcase.gsub(' ', '_') : item.downcase.gsub(' ', '_')
      room_items[item_key] = item
      "You drop the #{item.is_a?(Hash) ? item['name'] : item}."
    else
      "You don't have a #{item_name} to drop."
    end
  end

  def use_item(item_name, game_state)
    item = game_state.inventory.find do |i|
      i.is_a?(Hash) ? i['name'].downcase == item_name.downcase : i.downcase == item_name.downcase
    end
    return "You don't have a #{item_name} in your inventory." unless item

    item_key = item.is_a?(Hash) ? item['name'].downcase.gsub(' ', '_') : item.downcase
    item_data = @items[item_key]
    return "You can't use the #{item_name}." unless item_data

    case item_data['type']
    when 'consumable'
      use_consumable(item_name, item_data, game_state)
    when 'weapon'
      equip_weapon(item_name, item_data, game_state)
    when 'armor'
      equip_armor(item_name, item_data, game_state)
    else
      "You can't use the #{item_name}."
    end
  end

  private

  def use_consumable(item_name, item_data, game_state)
    return unless item_data['effect']['health']

    game_state.player['health'] += item_data['effect']['health']
    game_state.player['health'] = [game_state.player['health'], game_state.player['max_health']].min
    game_state.remove_from_inventory(item_name)
    "You use the #{item_name} and restore #{item_data['effect']['health']} health."
  end

  def equip_weapon(item_name, item_data, game_state)
    game_state.player['strength'] = 10 + item_data['damage']
    "You equip the #{item_name}. Your strength is now #{game_state.player['strength']}."
  end

  def equip_armor(item_name, item_data, game_state)
    game_state.player['defense'] = 5 + item_data['defense']
    "You equip the #{item_name}. Your defense is now #{game_state.player['defense']}."
  end
end
