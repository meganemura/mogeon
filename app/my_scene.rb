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
  end

  TILE_SIZE = 32

  def createSceneContents

    self.backgroundColor = SKColor.blackColor

    tilesheet = SKTexture.textureWithImageNamed("tilesheet")

    x = 6 * TILE_SIZE / tilesheet.size.width
    y = 6 * TILE_SIZE / tilesheet.size.height
    w =     TILE_SIZE / tilesheet.size.width
    h =     TILE_SIZE / tilesheet.size.height
    rect = CGRectMake(x, y, w, h)
    tile = SKTexture.textureWithRect(rect, inTexture: tilesheet)

    tile_width  = 10
    tile_height = 18

    tile_width.times do |i|
      tile_height.times do |j|

        position = CGPointMake(i * TILE_SIZE, j * TILE_SIZE)

        tile_sprite = SKSpriteNode.spriteNodeWithTexture(tile)

        tile_sprite.anchorPoint = CGPointMake(0, 0)
        tile_sprite.position = position
        self.addChild(tile_sprite)

        # Debug print
        pointLabel = SKLabelNode.labelNodeWithFontNamed("")
        pointLabel.text = "#{i + j * tile_width}"
        pointLabel.position = position
        pointLabel.fontSize = 9
        pointLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter
        self.addChild(pointLabel)
      end
    end
  end

  def touchesBegan(touches, withEvent: event)
    # touches.each do |touch|
    #   location = touch.locationInNode(self)
    #   sprite = SKSpriteNode.spriteNodeWithImageNamed("Spaceship")
    #   sprite.position = location
    #   action = SKAction.rotateByAngle(Math::PI, duration: 1)
    #   sprite.runAction(SKAction.repeatActionForever(action))
    #   self.addChild(sprite)
    # end
  end

  def update(current_time)
    # Called before each frame is rendered
  end
end
