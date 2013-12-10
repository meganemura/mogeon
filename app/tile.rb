module Mogeon
class Tile < SKTexture

  SIZE = 32

  class << self
    attr_reader :texture
    attr_reader :w, :h
    def texture=(texture)
      @texture = texture
      @w = SIZE / texture.size.width
      @h = SIZE / texture.size.height
    end

    def new(x, y)
      rect = CGRectMake(x * w, y * h, w, h)
      self.textureWithRect(rect, inTexture: texture)
    end
  end
end
end
