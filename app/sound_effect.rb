module Mogeon
  module SoundEffect
    class << self

      # TODO: Use metaprogramming
      def move_tiles
        @move_tiles ||= SKAction.playSoundFileNamed("chat.mp3", waitForCompletion: false)
      end

      def defeat
        @defeat ||= SKAction.playSoundFileNamed("kill1.mp3", waitForCompletion: false)
      end

    end
  end
end
