module Mogeon
class Unit < SKTexture
  class << self

    # TODO: Create unit subclass
    #   Unit.register('leatherarmor', as: :Friend)
    #     => Friend is subclass of Unit and defined
    def register(resource, as: klass)
      puts resource
      puts klass
    end

  end
end

# Friend クラスが texture を持っていて
# インスタンスが texture のどの場所を利用するかを持っていればいい
class Friend < SKSpriteNode
  SIZE = 64
  class << self
    attr_reader :texture
    attr_reader :w, :h
    def setup
      @texture = SKTexture.textureWithImageNamed("leatherarmor")
      @w = SIZE / texture.size.width
      @h = SIZE / texture.size.height
      @setup = true
    end

    def setup?
      !! @setup
    end

    def new(x, y)
      setup unless setup?
      rect = CGRectMake(x * w, y * h, w, h)
      texture = SKTexture.textureWithRect(rect, inTexture: @texture)
      instance = self.spriteNodeWithTexture(texture).tap do |sprite|
        sprite.x = x
        sprite.y = y
        sprite.anchorPoint = CGPointMake(0, 0)
      end

      instance
    end
  end

  attr_accessor :x, :y
end
end
