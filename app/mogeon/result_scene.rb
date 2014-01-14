module Mogeon
  class ResultScene < SKScene

    def initWithSize(size)
      super

      # BGM
      error = Pointer.new(:object)
      background_music_url = NSBundle.mainBundle.URLForResource("music/score", withExtension: "mp3")
      backgroundMusicPlayer = AVAudioPlayer.alloc.initWithContentsOfURL(background_music_url, error: error)
      backgroundMusicPlayer.numberOfLoops = -1
      backgroundMusicPlayer.prepareToPlay
      backgroundMusicPlayer.play

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
          SKAction.waitForDuration(3.0 * SPEED),
          SKAction.runBlock(lambda {
            backgroundMusicPlayer.stop
            reveal = SKTransition.flipHorizontalWithDuration(0.5 * SPEED)
            game_scene = GameScene.alloc.initWithSize(self.size)
            self.view.presentScene(game_scene, transition: reveal)
          }),
        ])
      )

      self
    end

  end
end
