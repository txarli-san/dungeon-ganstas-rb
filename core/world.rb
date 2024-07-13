class World
  def self.generate(game_data)
    available_items = YAML.load_file('data/items.yml')

    game_data['rooms'].each do |_room_key, room_data|
      # Convert items to hash if it's an array
      if room_data['items'].is_a?(Array)
        room_data['items'] = if room_data['items'].empty?
                               {}
                             else
                               room_data['items'].each_with_object({}) do |item, hash|
                                 if item.is_a?(String)
                                   hash[item] = available_items[item]
                                 else
                                   hash[item['name'].downcase.gsub(' ', '_')] = item
                                 end
                               end
                             end
      else
        room_data['items'] ||= {}
      end

      # Handle existing items
      room_data['items'].transform_values! do |item|
        item.is_a?(String) ? available_items[item] : item
      end

      # 1 in 4 chance to spawn an additional item in the room
      if rand(4) == 0
        item_key = available_items.keys.sample
        room_data['items'][item_key] = available_items[item_key]
      end
    end

    # Add loot to monsters
    game_data['rooms'].each do |_room_key, room_data|
      next unless room_data['monsters']

      room_data['monsters'].each do |_monster_key, monster_data|
        monster_data['loot'] ||= {}
        if rand(2) == 0 # 50% chance for a monster to have loot
          item_key = available_items.keys.sample
          monster_data['loot'][item_key] = available_items[item_key]
        end
      end
    end

    game_data
  end
end
