module Mogeon
  class Friend < Unit

    REAL_SIZE = 64
    SCALE = 1.0
    TEXTURE = "leatherarmor"

    def think_moving
      attack_target = around.find do |point|
        Map.movers.find { |mover| mover.x == point.first && mover.y == point.last }
      end

      if attack_target
        [attack_target.first - x, attack_target.last - y]
      else
        Map.moving_amount(:up)
      end
    end

  end
end
