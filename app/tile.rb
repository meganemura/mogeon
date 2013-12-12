module Mogeon
  class Tile < SKSpriteNode

    SIZE = 32

    class << self
      def new(texture)
        self.spriteNodeWithTexture(texture).tap do |node|
          node.anchorPoint = CGPointMake(0, 0)
        end
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
