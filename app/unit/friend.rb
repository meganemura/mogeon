module Mogeon
  class Friend < Unit::Base
    include Unit::Thinkable

    REAL_SIZE = 64
    SCALE = 1.0
    TEXTURE = "leatherarmor"

    def default_move
      Map.moving_amount(:up)
    end

    think_moving :attack_to_near_around
  end
end
