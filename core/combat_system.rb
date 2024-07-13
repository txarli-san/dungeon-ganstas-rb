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
    player = @game_state.player

    damage_dealt = [player.calculate_damage - (monster['defense'] || 0), 1].max
    monster['health'] -= damage_dealt
    response = "You attack the #{target} for #{damage_dealt} damage!"

    if monster['health'] <= 0
      monsters.delete(target)
      response += " The #{target} is defeated!"
    else
      monster_damage = [(monster['attack'] || 0) - player.calculate_defense, 1].max
      player.take_damage(monster_damage)
      response += " The #{target} counterattacks for #{monster_damage} damage!"

      response += ' You have been defeated. Game over!' if player.stats['health'] <= 0
    end

    response
  end
end
