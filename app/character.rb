module Mogeon
class Character < SKTexture
  class << self

    # TODO: Create character subclass
    #   Character.register('leatherarmor', as: :Friend)
    #     => Friend is subclass of Character and defined
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
      instance = self.spriteNodeWithTexture(texture)
      instance.x = x
      instance.y = y
      # tap で
      instance
    end
  end

  attr_accessor :x, :y
end
end
