module Mogeon
  class Tile < Unit

    REAL_SIZE = 32
    SCALE = 2.0
    SIZE = SCALE * REAL_SIZE
    TEXTURE = "tilesheet"

    class << self

      def size
        SCALE * REAL_SIZE
      end

    end

    def at
      position = self.position
      [(position.x / SIZE).to_i, (position.y / SIZE).to_i]
    end

  end
end
