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
          rect = CGRectMake(x * @w, y * @h, @w, @h)
          partial_texture = SKTexture.textureWithRect(rect, inTexture: @texture)

          instance = self.spriteNodeWithTexture(partial_texture).tap do |config|
            config.x = x
            config.y = y
            config.anchorPoint = [0, 0].to_point
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
        position = [@x, @y].to_point * self.class.size
        self.setPosition(position)
      end

      # (x, y) の差分を自分の position に追加する
      def move(x, y, &block)
        @x = (@x + x) % Map.columns
        @y = (@y + y) % Map.rows
        new_x = @x * self.class.size
        new_y = @y * self.class.size

        target_location = [new_x, new_y].to_point

        # self.runAction(move_action_with_done)
        action do
          move_action = SKAction.moveTo(target_location, duration: 0.2)

          if block
            [move_action, block.call].flatten
          else
            move_action
          end
        end

        return [@x, @y]
      end


      # マップ上の周りのユニットからどの方向に動くのかを決める
      #   処理内で Map.moving_amount 利用する?
      def think_moving
        # NOTE: 各継承先で実装が必要
        [0, 0]
      end

      def default_moves
        [0, 0]
      end

      # 自分の視野 think_moving の実装に利用
      #   標準は現在地の周囲8マス
      def sight
        [
          # 上下左右が優先
          [x + 0, y - 1],
          [x - 1, y + 0],
          [x + 1, y + 0],
          [x + 0, y + 1],

          # ナナメは優先度低
          [x - 1, y - 1],
          [x + 1, y - 1],
          [x - 1, y + 1],
          [x + 1, y + 1],
        ]
      end


      def with_nodes_of_sight
        [self] + nodes_of_sight
      end

      # sight にある tile を返す
      def nodes_of_sight
        Map.tiles.select {|tile| self.sight.include?([tile.x, tile.y]) }
      end

      def action(&block)
        if block
          action = block.call
          case action
          when Array
            self.runAction(SKAction.sequence(action))
          else
            self.runAction(action)
          end
        end
      end

    end
  end
end
