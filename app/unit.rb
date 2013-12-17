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
      @x += x
      @y += y
      new_x = (@x * self.class.size) % Map.width
      new_y = (@y * self.class.size) % Map.height

      target_location = CGPointMake(new_x, new_y)

      move_duration = 0.5
      move_action = SKAction.moveTo(target_location, duration: move_duration)
      move_action_with_done = SKAction.sequence([move_action, callback].compact)
      self.runAction(move_action_with_done, withKey: "tile_moving")
    end


    # activate/deactivate/active?
    # このユニットが現在動かす対象かどうか
    #     全てのユニットがこのパラメータを持つよりも
    #     動かす対象のユニットをひとつ持つほうが良さそう
    # TODO:
    #   Player 2回行動
    #   Friend 1回行動、のように変動できるようにしたい
    def activate
      @active = true
    end

    def deactivate
      @active = false
    end

    def active?
      !! @active
    end
  end
end
