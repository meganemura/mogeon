module Mogeon
  class Unit < SKSpriteNode

    REAL_SIZE = 0
    SCALE = 1.0
    TEXTURE = ""
    Z_POSITION = 0

    class << self

      attr_accessor :tile_size

      # テクスチャの (x, y) を Sprite として利用する
      def new(x, y)
        setup_once
        rect = CGRectMake(x * @w, y * @h, @w, @h)
        partial_texture = SKTexture.textureWithRect(rect, inTexture: @texture)

        instance = self.spriteNodeWithTexture(partial_texture).tap do |config|
          config.x = x
          config.y = y
          config.anchorPoint = CGPointMake(0, 0)
          config.scale = self::SCALE
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

      def size
        self::REAL_SIZE * self::SCALE
      end
    end

    attr_accessor :x, :y

    def locate(x, y)
      @x = x
      @y = y
      position = CGPointMake(@x * self.class.size, @y * self.class.size)
      self.setPosition(position)
    end

    # (x, y) の差分を自分の position に追加する
    def move(x, y, callback = nil)
      @x = (@x + x) % Map.columns
      @y = (@y + y) % Map.rows
      new_x = @x * self.class.size
      new_y = @y * self.class.size

      target_location = CGPointMake(new_x, new_y)

      move_duration = 0.5
      move_action = SKAction.moveTo(target_location, duration: move_duration)
      move_action_with_done = SKAction.sequence([move_action, callback].compact)
      self.runAction(move_action_with_done, withKey: "tile_moving")

      return [@x, @y]
    end
  end
end
