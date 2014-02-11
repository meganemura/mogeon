module Mogeon
  module SoundEffect
    class << self

      # TODO: Use metaprogramming
      def move_tiles
        @move_tiles ||= SKAction.playSoundFileNamed("sounds/chat.mp3", waitForCompletion: false)
      end

      def defeat
        @defeat ||= SKAction.playSoundFileNamed("sounds/kill1.mp3", waitForCompletion: false)
      end

    end
  end
end
