module Mogeon
  module Unit
    class Body < Unit::Base

      Z_POSITION = 1

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

    end
  end
end
