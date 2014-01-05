module Mogeon
  class MenuScene < SKScene
    def initWithSize(size)
      super
      self
    end

    def didMoveToView(view)
      # Start Game Label
      label = SKLabelNode.labelNodeWithFontNamed("Chalkduster")
      label.text = "Mogeon"
      label.fontSize = 40
      label.fontColor = SKColor.whiteColor
      label.position = [self.size.width, self.size.height].to_point / 2
      self.addChild(label)
    end

    def touchesBegan(touches, withEvent: event)
      touches.each do |touch|
        location = touch.locationInNode(self)
        friend = Friend.new(0, 0)
        friend.position = location
        friend.runAction(
          SKAction.sequence([
            SKAction.rotateByAngle(2 * Math::PI, duration: 0.5 * SPEED),
            SKAction.runBlock(lambda {
              reveal = SKTransition.doorsOpenHorizontalWithDuration(1.0 * SPEED)
              my_scene = GameScene.alloc.initWithSize(self.size)
              my_scene.scaleMode = SKSceneScaleModeAspectFill
              self.view.presentScene(my_scene, transition: reveal)
            }),
          ])
        )
        self.addChild(friend)
      end
    end

  end
end
