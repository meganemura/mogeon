module Mogeon

  class Map
    class << self

      def size=(size)
        @texture = SKTexture.textureWithImageNamed("tilesheet")

        @columns  = (size.width  / Tile::SIZE).to_i
        @rows     = (size.height / Tile::SIZE).to_i
      end

      def width
        @columns * Tile::SIZE
      end

      def height
        @rows * Tile::SIZE
      end


      # texture locate in (x, y)
      def tile_texture(x, y)
        @w ||= Tile::SIZE / @texture.size.width
        @h ||= Tile::SIZE / @texture.size.height
        rect = CGRectMake(x * @w, y * @h, @w, @h)
        SKTexture.textureWithRect(rect, inTexture: @texture)
      end

      def lay_tiles
        tile1 = tile_texture(6, 6)
        tile2 = tile_texture(5, 6)

        tiles = []
        @columns.times do |column|
          @rows.times do |row|
            if (column + row) % 2 == 0
              tile = Tile.new(tile1)
            else
              tile = Tile.new(tile2)
            end
            tile.locate(column, row)
            tiles << tile
          end
        end

        tiles
      end

      def tiles
        @tiles ||= lay_tiles
      end
    end
  end
end
