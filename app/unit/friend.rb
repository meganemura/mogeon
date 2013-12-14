module Mogeon
  class Friend < Unit

    REAL_SIZE = 64
    SCALE = 1.0
    TEXTURE = "leatherarmor"

    def random_move(callback)
      x, y = Map.moving_amount(random_direction)
      self.move(x, y, callback)
    end

    def random_direction
      case rand(4)
      when 0
        :up
      when 1
        :right
      when 2
        :down
      when 3
        :left
      end
    end

  end
end
