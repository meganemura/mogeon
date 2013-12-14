module Mogeon

  class Map
    class << self

      def size=(size)
        @columns  = (size.width  / Tile::SIZE).to_i
        @rows     = (size.height / Tile::SIZE).to_i
      end

      def width
        @columns * Tile::SIZE
      end

      def height
        @rows * Tile::SIZE
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
          [Tile::SIZE,  0]
        when :left
          [-Tile::SIZE, 0]
        when :up
          [0,  Tile::SIZE]
        when :down
          [0, -Tile::SIZE]
        end
      end
    end
  end
end
