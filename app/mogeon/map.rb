module Mogeon

  class Map
    class << self

      attr_reader :columns, :rows
      def size=(size)
        @columns  = (size.width  / Tile.size).to_i
        @rows     = (size.height / Tile.size).to_i
      end

      def width
        @columns * Tile.size
      end

      def height
        @rows * Tile.size
      end

      def friends
        @friends ||= []
      end

      def enemies
        @enemies ||= []
      end

      def movers
        friends + enemies
      end

      def clear!
        @friends = nil
        @enemies = nil
      end

      # Map の (x, y) に存在する Unit を返す
      def at(x, y)
        Map.movers.find {|mover| mover.x == x && mover.y == y }
      end

      # Map の (x, y) に存在する Tile を返す
      def tile_at(x, y)
        Map.tiles.find {|tile| tile.x == x && tile.y == y }
      end

      # 誰もいない場所(スペース)を返す
      # TODO: 効率の良いアルゴリズムにする
      def space(x = nil, y = nil)
        if x && y
          unless Map.movers.find {|o| o.x == x && o.y == y }
            return [x, y]
          end
        elsif x && !y
          (0...rows).to_a.shuffle.each do |new_y|
            unless Map.movers.find {|o| o.x == x && o.y == new_y}
              return [x, new_y]
            end
          end
        elsif !x && y
          (0...columns).to_a.shuffle.each do |new_x|
            unless Map.movers.find {|o| o.x == new_x && o.y == y }
              return [new_x, y]
            end
          end
        end

        nil
      end

      def tiles
        @tiles ||= lay_tiles
      end

      def lay_tiles
        tiles = []
        @columns.times do |column|
          @rows.times do |row|
            if (column + row) % 2 == 0
              tile = Tile.new(6, 6)
            else
              tile = Tile.new(6, 6)
              # tile = Tile.new(5, 6)
            end
            tile.locate(column, row)
            tiles << tile
          end
        end
        tiles
      end

      def moving_amount(direction)
        case direction
        when :right
          [1,  0]
        when :left
          [-1, 0]
        when :up
          [0,  1]
        when :down
          [0, -1]
        end
      end

      # 不要なタイルをスタック
      #   TODO: 再利用する
      def garbage_collect
        @tiles, garbages = @tiles.partition do |tile|
          0 <= tile.x && tile.x < Map.columns && 0 <= tile.y && tile.y < Map.rows
        end

        @garbages ||= []
        garbages.each do |garbage|
          garbage.hidden = true
          @garbages << garbage
        end
      end

    end
  end
end
