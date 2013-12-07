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

    gesture_recognizer = UIPanGestureRecognizer.alloc.initWithTarget(self, action: 'handle_pan_from:')
    self.view.addGestureRecognizer(gesture_recognizer)
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

    tile_width  = 10
    tile_height = 18
    tile_width.times do |i|
      tile_height.times do |j|

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

  def handle_pan_from(recognizer)
    case recognizer.state
    when UIGestureRecognizerStateBegan
      touch_location = recognizer.locationInView(recognizer.view)
      touch_location = self.convertPointFromView(touch_location)
      self.select_node_for_touch(touch_location)
    when UIGestureRecognizerStateChanged
      translation = recognizer.translationInView(recognizer.view)
      translation = CGPointMake(translation.x, -translation.y)
      self.pan_for_translation(translation)
      recognizer.setTranslation(CGPointZero, inView: recognizer.view)
    when UIGestureRecognizerStateEnded
    end
  end

  def select_node_for_touch(touch_location)
    touched_node = self.nodeAtPoint(touch_location)
    puts touched_node.inspect
    @selected_node = touched_node
  end

  def pan_for_translation(translation)
    position = @selected_node.position
    if @selected_node.is_a? SKSpriteNode
      @selected_node.setPosition(CGPointMake(position.x + translation.x, position.y + translation.y))
    end
  end


end
