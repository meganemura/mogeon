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


  TILE_SIZE = 32
  def createSceneContents

    self.backgroundColor = SKColor.darkGrayColor

    tilesheet = SKTexture.textureWithImageNamed("tilesheet")

    # define 2 tiles
    w =     TILE_SIZE / tilesheet.size.width
    h =     TILE_SIZE / tilesheet.size.height

    # tile 1
    x = 6 * TILE_SIZE / tilesheet.size.width
    y = 6 * TILE_SIZE / tilesheet.size.height
    rect = CGRectMake(x, y, w, h)
    tile1 = SKTexture.textureWithRect(rect, inTexture: tilesheet)

    # tile 2
    x = 5 * TILE_SIZE / tilesheet.size.width
    y = 6 * TILE_SIZE / tilesheet.size.height
    rect = CGRectMake(x, y, w, h)
    tile2 = SKTexture.textureWithRect(rect, inTexture: tilesheet)

    @tiles = []

    @tile_width  = (self.frame.size.width / TILE_SIZE).to_i
    @tile_height = (self.frame.size.height / TILE_SIZE).to_i
    puts "#{@tile_width}, #{@tile_height}"

    @tile_width.times do |i|
      @tile_height.times do |j|

        position = CGPointMake(i * TILE_SIZE, j * TILE_SIZE)

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
      [TILE_SIZE, 0]
    when :left
      [-TILE_SIZE, 0]
    when :up
      [0, TILE_SIZE]
    when :down
      [0, -TILE_SIZE]
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
      puts moving_nodes.size
    when :up, :down
      moving_nodes = @tiles.select do |tile|
        tile.position.x == touched_at.x
      end
      puts moving_nodes.size
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
    @tile_height * TILE_SIZE
  end

  def max_width
    @tile_width * TILE_SIZE
  end

end
