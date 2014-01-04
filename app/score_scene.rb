module Mogeon
  class ScoreScene < SKScene

    def initWithSize(size)
      super

      self.backgroundColor = SKColor.colorWithRed(1.0, green: 1.0, blue: 1.0, alpha: 1.0)

      # Label
      label = SKLabelNode.labelNodeWithFontNamed("Chalkduster")
      label.text = "Cleared"
      label.fontSize = 40
      label.fontColor = SKColor.blackColor
      label.position = CGPointMake(self.size.width / 2, self.size.height / 2)
      self.addChild(label)

      # Effect
      self.runAction(
        SKAction.sequence([
          SKAction.waitForDuration(3.0),
          SKAction.runBlock(lambda {
            reveal = SKTransition.flipHorizontalWithDuration(0.5)
            game_scene = GameScene.alloc.initWithSize(self.size)
            self.view.presentScene(game_scene, transition: reveal)
          }),
        ])
      )

      self
    end

  end
end
