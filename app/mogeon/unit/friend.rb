module Mogeon
  class Friend < Unit::Body
    include Unit::Thinkable

    REAL_SIZE = 64
    SCALE = 1.0
    TEXTURE = "leatherarmor"

    def default_moves
      [
        [x + 0, y + 1],
        [x - 1, y + 0],
        [x + 1, y + 0],
      ]
    end

    think_moving :attack_to_near_around
  end
end
