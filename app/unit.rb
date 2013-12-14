module Mogeon
class Unit < SKSpriteNode
  class << self

    attr_accessor :tile_size

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
class Friend < Unit
  SIZE = 64
  class << self
    def setup
      @texture = SKTexture.textureWithImageNamed("leatherarmor")
      @w = SIZE / @texture.size.width
      @h = SIZE / @texture.size.height
      @setup = true
    end

    def setup?
      !! @setup
    end

    def new(x, y)
      setup unless setup?
      rect = CGRectMake(x * @w, y * @h, @w, @h)
      partial_texture = SKTexture.textureWithRect(rect, inTexture: @texture)
      instance = self.spriteNodeWithTexture(partial_texture).tap do |config|
        config.x = x
        config.y = y
        config.anchorPoint = CGPointMake(0, 0)
        config.locate(x, y)
        config.zPosition = 1
      end

      instance
    end
  end

  attr_accessor :x, :y

  def locate(x, y)
    @x = x
    @y = y
    position = CGPointMake(@x * self.class.tile_size, @y * self.class.tile_size)
    self.setPosition(position)
  end

end
end
