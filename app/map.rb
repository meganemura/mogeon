module Mogeon

  class Map < SKSpriteNode
    TILE_SIZE = 32

    class << self

      def size=(size)
        @texture = SKTexture.textureWithImageNamed("tilesheet")

        @columns  = (size.width  / TILE_SIZE).to_i
        @rows     = (size.height / TILE_SIZE).to_i
      end

      def width
        @columns * TILE_SIZE
      end

      def height
        @rows * TILE_SIZE
      end


      # texture locate in (x, y)
      def tile_texture(x, y)
        @w ||= TILE_SIZE / @texture.size.width
        @h ||= TILE_SIZE / @texture.size.height
        rect = CGRectMake(x * @w, y * @h, @w, @h)
        SKTexture.textureWithRect(rect, inTexture: @texture)
      end

      def lay_tiles
        tile1 = tile_texture(6, 6)
        tile2 = tile_texture(5, 6)

        tiles = []
        @columns.times do |column|
          @rows.times do |row|

            position = CGPointMake(column * TILE_SIZE, row * TILE_SIZE)

            if column % 2 == 0
              tile_sprite = SKSpriteNode.spriteNodeWithTexture(tile1)
            else
              tile_sprite = SKSpriteNode.spriteNodeWithTexture(tile2)
            end

            tile_sprite.anchorPoint = CGPointMake(0, 0)
            tile_sprite.position = position
            tiles << tile_sprite
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
