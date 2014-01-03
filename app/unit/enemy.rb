module Mogeon
  class Enemy < Unit::Body
    include Unit::Thinkable

    REAL_SIZE = 32
    SCALE = 2.0
    TEXTURE = "bat"

    def default_moves
      [
        [x + 0, y - 1],
        [x - 1, y + 0],
        [x + 1, y + 0],
      ]
    end

    think_moving :attack_to_near_around
  end
end
