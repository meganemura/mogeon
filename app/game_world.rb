module Mogeon
  class GameWorld
    def initialize(scene)
      @scene = scene
      setup_map
      setup_hud
      setup_sound_effect
      setup_background_music
      setup_units
    end

    def setup_map
      Map.size = @scene.frame.size
      Map.tiles.each do |tile|
        tile.removeFromParent
        @scene << tile
      end
    end

    def setup_hud
      # State HUD
      state_hud = StateHud.new("State:")
      state_hud.position = [
        20 + state_hud.frame.size.width / 2,
        @scene.size.height - (20 + state_hud.frame.size.height)
      ].to_point
      @scene.addChild(state_hud)
    end

    # pre-loading
    def setup_sound_effect
      SoundEffect.move_tiles
    end

    attr_accessor :backgroundMusicPlayer
    def setup_background_music
      error = Pointer.new(:object)
      background_music_url = NSBundle.mainBundle.URLForResource("music/desert", withExtension: "mp3")
      self.backgroundMusicPlayer = AVAudioPlayer.alloc.initWithContentsOfURL(background_music_url, error: error)
      self.backgroundMusicPlayer.numberOfLoops = -1
      self.backgroundMusicPlayer.prepareToPlay
      self.backgroundMusicPlayer.play
    end

    DEFAULT_FRIEND_SIZE = 2
    DEFAULT_ENEMY_SIZE  = 2
    def setup_units
      # setup friends
      DEFAULT_FRIEND_SIZE.times do
        friend = Friend.new(0, 0)
        x, y = Map.space(nil, 0)
        friend.locate(x, y)

        Map.friends << friend
        @scene.addChild(friend)
      end

      # setup enemies
      DEFAULT_ENEMY_SIZE.times do
        enemy = Enemy.new(0, 0)
        x, y = Map.space(nil, Map.rows - 1)
        enemy.locate(x, y)

        Map.enemies << enemy
        @scene.addChild(enemy)
      end

      # setup neutrals
    end
  end
end
