module Mogeon
  module Unit
    class Base < SKSpriteNode

      REAL_SIZE = 0
      SCALE = 1.0
      TEXTURE = ""
      Z_POSITION = 0

      class << self

        attr_accessor :tile_size

        # テクスチャの (x, y) を Sprite として利用する
        def new(x, y)
          setup_once

          instance = self.spriteNodeWithTexture(partial_texture(x, y)).tap do |config|
            config.x = x
            config.y = y
            # config.anchorPoint = [0.5, 0.5] # default
            config.scale = self::SCALE
            config.zPosition = self::Z_POSITION
          end

          instance
        end

        def partial_texture(x, y)
          rect = CGRectMake(x * @w, y * @h, @w, @h)
          SKTexture.textureWithRect(rect, inTexture: @texture)
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

        def anchor_point_offset
          self::REAL_SIZE * self::SCALE * 0.5
        end
      end

      attr_accessor :x, :y

      def locate(x, y)
        @x = x
        @y = y
        position = [@x, @y].to_point * self.class.size + self.class.anchor_point_offset
        self.setPosition(position)
      end

      # absolute
      def move_to(x, y, inside = false)
        if inside
          x, y = force_inside(x, y)
        end
        @x = x
        @y = y
        target_location = [@x * self.class.size, @y * self.class.size].to_point + self.class.anchor_point_offset
        SKAction.moveTo(target_location, duration: 0.2 * SPEED)
      end

      # relative
      # (x, y) の差分を自分の position に追加して move_to に渡す
      def move_by(dx, dy, inside = false)
        x, y = moved_point(dx, dy)
        move_to(x, y, inside)
      end

      def moved_point(dx, dy)
        map_x = (@x + dx) # % Map.columns
        map_y = (@y + dy) # % Map.rows
        [map_x, map_y]
      end

      # Map 内におさめる
      def force_inside(x, y)
        if x < 0
          x = 0
        elsif x >= Map.columns
          x = Map.columns - 1
        end

        if y < 0
          y = 0
        elsif y >= Map.rows
          y = Map.rows - 1
        end

        [x, y]
      end

      def actions
        @actions ||= []
      end

      def run_actions
        self.runAction(SKAction.sequence(@actions.flatten))
        @actions = []
      end

      def forever
        sequence = SKAction.sequence(actions)
        @actions = [SKAction.repeatActionForever(sequence)]
        run_actions
      end

      def stop_motion
        self.removeAllActions
        actions << SKAction.rotateToAngle(degrees_to_radians(0), duration: 0.1 * SPEED)
        self
      end

    end
  end
end
