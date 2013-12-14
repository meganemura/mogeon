module Mogeon
  class Unit < SKSpriteNode

    REAL_SIZE = 0
    SCALE = 1.0
    SIZE = SCALE * REAL_SIZE
    TEXTURE = ""
    Z_POSITION = 0

    class << self

      attr_accessor :tile_size

      def new(x, y)
        setup_once
        rect = CGRectMake(x * @w, y * @h, @w, @h)
        partial_texture = SKTexture.textureWithRect(rect, inTexture: @texture)

        instance = self.spriteNodeWithTexture(partial_texture).tap do |config|
          config.x = x
          config.y = y
          config.anchorPoint = CGPointMake(0, 0)
          config.scale = self::SCALE
          config.locate(x, y)
          config.zPosition = self::Z_POSITION
        end

        instance
      end

      def setup_once
        unless @setup_done
          @setup_done = true
          @texture = SKTexture.textureWithImageNamed(self::TEXTURE)
          @w = self::REAL_SIZE / @texture.size.width
          @h = self::REAL_SIZE / @texture.size.height
        end
      end
    end

    attr_accessor :x, :y

    def locate(x, y)
      @x = x
      @y = y
      position = CGPointMake(@x * self.class::SIZE, @y * self.class::SIZE)
      self.setPosition(position)
    end
  end
end
