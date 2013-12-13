module Mogeon
  class Tile < SKSpriteNode

    REAL_SIZE = 32
    SCALE = 2.0
    SIZE = SCALE * REAL_SIZE

    TEXTURE = SKTexture.textureWithImageNamed("tilesheet")

    class << self
      def new(x, y)
        texture = tile_at_texture(x, y)
        self.spriteNodeWithTexture(texture).tap do |node|
          node.anchorPoint = CGPointMake(0, 0)
          node.scale = SCALE
        end
      end

      def size
        SCALE * SIZE
      end

      def tile_at_texture(x, y)
        w = REAL_SIZE / TEXTURE.size.width
        h = REAL_SIZE / TEXTURE.size.height
        rect = CGRectMake(x * w, y * h, w, h)
        SKTexture.textureWithRect(rect, inTexture: TEXTURE)
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
