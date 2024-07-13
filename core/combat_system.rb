class CombatSystem
  def initialize(game_state)
    @game_state = game_state
  end

  def attack(target, current_room)
    monsters = @game_state.get_room_data(current_room)['monsters']
    return 'There are no monsters here to attack.' unless monsters&.any?

    if target.nil?
      unless monsters.keys.length == 1
        return "Which monster do you want to attack? Options: #{monsters.keys.join(', ')}"
      end

      target = monsters.keys.first
    end

    return "There's no #{target} here to attack." unless monsters.key?(target)

    monster = monsters[target]
    damage_dealt = @game_state.player['strength'] - (monster['defense'] || 0)
    damage_dealt = 1 if damage_dealt < 1

    monster['health'] -= damage_dealt
    response = "You attack the #{target} for #{damage_dealt} damage!"

    if monster['health'] <= 0
      monsters.delete(target)
      response += " The #{target} is defeated!"
    else
      monster_damage = (monster['attack'] || 0) - @game_state.player['defense']
      monster_damage = 1 if monster_damage < 1
      @game_state.player['health'] -= monster_damage
      response += " The #{target} counterattacks for #{monster_damage} damage!"

      response += ' You have been defeated. Game over!' if @game_state.player['health'] <= 0
    end

    response
  end
end
