module Mogeon
  module Effect

    class << self

      # scale up => scale down
      def balloon(current_scale)
        [
          SKAction.scaleBy(1.5, duration: 0.05 * SPEED),
          SKAction.scaleTo(current_scale, duration: 0.3 * SPEED),
        ]
      end

    end
  end
end
