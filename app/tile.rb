module Mogeon
  class Tile < SKSpriteNode

    REAL_SIZE = 32
    SCALE = 2.0
    SIZE = SCALE * REAL_SIZE

    class << self
      def new(texture)
        self.spriteNodeWithTexture(texture).tap do |node|
          node.anchorPoint = CGPointMake(0, 0)
          node.scale = SCALE
        end
      end

      def size
        SCALE * SIZE
      end
    end

    def locate(x, y)
      self.position = CGPointMake(x * SIZE, y * SIZE)
    end

    def at
      position = self.position
      [(position.x / SIZE).to_i, (position.y / SIZE).to_i]
    end

  end
end
