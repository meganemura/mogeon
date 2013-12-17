module Mogeon

  class Map
    class << self

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
