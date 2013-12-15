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
      label.position = CGPointMake(self.size.width / 2, self.size.height / 2)
      self.addChild(label)
    end

    def touchesBegan(touches, withEvent: event)
      touches.each do |touch|
        location = touch.locationInNode(self)
        friend = Friend.new(0, 0)
        friend.position = location
        friend.runAction(
          SKAction.sequence([
            SKAction.rotateByAngle(2 * Math::PI, duration: 0.5),
            SKAction.runBlock(lambda {
              reveal = SKTransition.doorsOpenHorizontalWithDuration(1.0)
              my_scene = MyScene.alloc.initWithSize(self.size)
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
