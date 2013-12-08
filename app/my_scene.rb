class MyScene < SKScene
  def initWithSize(size)
    super

    self
  end

  def didMoveToView(view)
    if !@contentCreated
      self.createSceneContents
      @contentCreated = true
    end

    [
      UISwipeGestureRecognizerDirectionRight,
      UISwipeGestureRecognizerDirectionLeft,
      UISwipeGestureRecognizerDirectionUp,
      UISwipeGestureRecognizerDirectionDown,
    ].each do |direction|
      swipe_recognizer = UISwipeGestureRecognizer.alloc.initWithTarget(self, action: 'swipe:')
      swipe_recognizer.direction = direction
      self.view.addGestureRecognizer(swipe_recognizer)
    end
  end

  def createSceneContents

    self.backgroundColor = SKColor.darkGrayColor

    tilesheet = SKTexture.textureWithImageNamed("tilesheet")

    Tile.texture = tilesheet
    tile1 = Tile.new(6, 6)
    tile2 = Tile.new(5, 6)

    @tiles = []

    @tile_width  = (self.frame.size.width / Tile::SIZE).to_i
    @tile_height = (self.frame.size.height / Tile::SIZE).to_i

    @tile_width.times do |i|
      @tile_height.times do |j|

        position = CGPointMake(i * Tile::SIZE, j * Tile::SIZE)

        if i % 2 == 0
          tile_sprite = SKSpriteNode.spriteNodeWithTexture(tile1)
        else
          tile_sprite = SKSpriteNode.spriteNodeWithTexture(tile2)
        end

        tile_sprite.anchorPoint = CGPointMake(0, 0)
        tile_sprite.position = position
        @tiles << tile_sprite
        self.addChild(tile_sprite)
      end
    end
  end

  def update(current_time)
    # Called before each frame is rendered
  end

  # UISwipeGestureRecognizer
  def swipe(recognizer)
    case recognizer.state
    when UIGestureRecognizerStateRecognized
      touch_location = recognizer.locationInView(recognizer.view)
      touch_location = self.convertPointFromView(touch_location)
      direction = DIRECTION_MAP[recognizer.direction]
      self.swipe_node(touch_location, direction)
    end
  end

  DIRECTION_MAP = {
    (1 << 0) => :right,
    (1 << 1) => :left,
    (1 << 2) => :up,
    (1 << 3) => :down,
  }

  def moving_amount(direction)
    case direction
    when :right
      [Tile::SIZE, 0]
    when :left
      [-Tile::SIZE, 0]
    when :up
      [0, Tile::SIZE]
    when :down
      [0, -Tile::SIZE]
    end
  end

  def swipe_node(touch_location, direction)
    touched_node = self.nodeAtPoint(touch_location)
    return unless touched_node.is_a? SKSpriteNode

    touched_at = touched_node.position
    case direction
    when :right, :left
      moving_nodes = @tiles.select do |tile|
        tile.position.y == touched_at.y
      end
    when :up, :down
      moving_nodes = @tiles.select do |tile|
        tile.position.x == touched_at.x
      end
    end

    x, y = moving_amount(direction)
    moving_nodes.each do |node|
      node_at = node.position

      new_x = node_at.x + x
      new_y = node_at.y + y

      if new_x < 0
        new_x += max_width
      elsif new_x >= max_width
        new_x -= max_width
      end

      if new_y < 0
        new_y += max_height
      elsif new_y >= max_height
        new_y -= max_height
      end

      node.setPosition(CGPointMake(new_x, new_y))
    end
  end

  def max_height
    @tile_height * Tile::SIZE
  end

  def max_width
    @tile_width * Tile::SIZE
  end

end
