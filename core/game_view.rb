require 'byebug'

class GameView
  FIXED_WIDTH = 80
  FIXED_HEIGHT = 24

  def self.draw_layout(title, hp, attack, defense, text)
    heart = '♥'
    sword = '⚔'
    shield = '⛨'
    stats = "#{sword} #{attack}  #{shield} #{defense}  #{heart} #{hp}"

    output = []
    output << "\x1b[?25l"  # hide cursor
    output << "\x1b[2J"    # cls
    output << "\x1b[H"     # set cursor to top-left corner

    # Header
    output << title.ljust(FIXED_WIDTH - stats.length) + stats
    output << '─' * FIXED_WIDTH

    # Main output
    wrapped_text = wrap_text(text, FIXED_WIDTH)
    (0...FIXED_HEIGHT - 3).each do |i|
      output << if i < wrapped_text.length
                  wrapped_text[i].ljust(FIXED_WIDTH)
                else
                  ' '.ljust(FIXED_WIDTH)
                end
    end

    # Cursor positioning
    output << "\x1b[#{FIXED_HEIGHT};2H" # position after '>'
    output << "\x1b[?25h"  # show
    output << "\x1b[5m"    # blink
    output << ' '          # blinking space
    output << "\x1b[0m"    # reset

    output.join("\r\n")
  end

  def self.wrap_text(text, width)
    lines = []
    text.split("\r\n").each do |line|
      while line.length > width
        break_point = line[0...width].rindex(' ') || width
        lines << line[0...break_point].strip
        line = line[break_point..-1].strip
      end
      lines << line if line.length > 0
    end
    lines
  end

  def self.format_response(engine, response)
    draw_layout(
      engine.game_state.current_room.capitalize,
      engine.game_state.player.stats['health'].to_s + '/' + engine.game_state.player.stats['max_health'].to_s,
      engine.game_state.player.stats['attack'].to_s,
      engine.game_state.player.stats['defense'].to_s,
      response
    )
  end
end
