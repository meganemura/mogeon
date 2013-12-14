module Mogeon
  class Unit < SKSpriteNode
    class << self

      attr_accessor :tile_size

      def setup
        @texture = SKTexture.textureWithImageNamed(self::TEXTURE)
        @w = self::SIZE / @texture.size.width
        @h = self::SIZE / @texture.size.height
        @setup = true
      end

      def setup?
        !! @setup
      end

      def new(x, y)
        setup unless setup?
        rect = CGRectMake(x * @w, y * @h, @w, @h)
        partial_texture = SKTexture.textureWithRect(rect, inTexture: @texture)
        instance = self.spriteNodeWithTexture(partial_texture).tap do |config|
          config.x = x
          config.y = y
          config.anchorPoint = CGPointMake(0, 0)
          config.locate(x, y)
          config.zPosition = 1
        end

        instance
      end
    end

    attr_accessor :x, :y

    def locate(x, y)
      @x = x
      @y = y
      position = CGPointMake(@x * self.class.tile_size, @y * self.class.tile_size)
      self.setPosition(position)
    end

  end

  class Friend < Unit
    SIZE = 64
    TEXTURE = "leatherarmor"
  end
end
