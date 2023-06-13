require 'gosu'

class Player
  attr_reader :x, :y, :size, :game_over

  def initialize(x, y, size, color)
    @x = x
    @y = y
    @size = size
    @color = color
    @jumping = false
    @jump_velocity = 10.0
    @gravity = 0.4
    @speed = 5
    @time = 0.0
    @game_over = false
  end

  def update(platform_y, platform_height)
    if Gosu.button_down?(Gosu::KB_LEFT) && @x > 0
      @x -= @speed
    end

    if Gosu.button_down?(Gosu::KB_RIGHT)
      @x += @speed
    end

    if Gosu.button_down?(Gosu::KB_UP) && !@jumping
      @jumping = true
      @time = 0.0
    end

    if @jumping
      @y = platform_y - @size - calculate_jump_height(platform_height)
      @time += 1.0
      if @time >= calculate_total_time(platform_height)
        @jumping = false
        @time = 0.0
      end
    else
      @y = platform_y - @size
    end

    if @y > platform_y + platform_height
      @game_over = true
    end
  end

  def calculate_jump_height(platform_height)
    return @jump_velocity * @time - 0.5 * @gravity * @time**2
  end

  def calculate_total_time(platform_height)
    return (2 * @jump_velocity) / @gravity
  end

  def draw
    Gosu.draw_rect(x, y, size, size, @color)
  end
end

class GameWindow < Gosu::Window
  def initialize
    super(640, 480)
    self.caption = "Simple Platformer"

    @platform_y = height * 0.96
    @platform_height = 20

    @player = Player.new(0, @platform_y - 50 + @platform_height, 30, Gosu::Color::GREEN)

    @game_over_font = Gosu::Font.new(30)
    @game_over = false
    @restart_option = Gosu::Image.from_text("Press R to restart", 30)
  end

  def update
    @player.update(@platform_y, @platform_height)

    if @player.game_over
      @game_over = true
    end
  end

  def draw
    draw_quad(0, @platform_y, Gosu::Color::GRAY,
              width, @platform_y, Gosu::Color::GRAY,
              0, @platform_y + @platform_height, Gosu::Color::GRAY,
              width, @platform_y + @platform_height, Gosu::Color::GRAY)

    @player.draw

    if @game_over
      @game_over_font.draw_text("Game Over", width / 2 - 80, height / 2 - 15, 1)
      @restart_option.draw(width / 2 - @restart_option.width / 2, height / 2 + 15, 1)
    end
  end

  def button_down(id)
    if id == Gosu::KB_R && @game_over
      restart_game
    else
      super
    end
  end

  def restart_game
    @player = Player.new(0, @platform_y - 50 + @platform_height, 30, Gosu::Color::GREEN)
    @game_over = false
  end
end

window = GameWindow.new
window.show

