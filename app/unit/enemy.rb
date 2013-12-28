module Mogeon
  class Enemy < Unit
    include Thinkable

    REAL_SIZE = 32
    SCALE = 2.0
    TEXTURE = "bat"

    def default_move
      Map.moving_amount(:down)
    end

    think_moving :attack_to_near_around
  end
end
