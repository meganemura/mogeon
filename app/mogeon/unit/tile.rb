module Mogeon
  class Tile < Unit::Base

    REAL_SIZE = 32
    SCALE = 2.0
    TEXTURE = "tilesheet"

    def at
      position = self.position
      [(position.x / self.class.size).to_i, (position.y / self.class.size).to_i]
    end

  end
end
