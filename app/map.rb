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
              tile = Tile.new(5, 6)
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
    end
  end
end
