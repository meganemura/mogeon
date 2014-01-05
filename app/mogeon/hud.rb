module Mogeon
  class Hud < SKLabelNode
  end

  class StateHud < Hud
    NAME = 'StateHud::NAME'.freeze
    class << self
      def new(message = "")
        self.labelNodeWithFontNamed("Courier").tap do |config|
          config.name = StateHud::NAME
          config.fontSize = 15
          config.fontColor = SKColor.greenColor
          config.text = "State: #{message}"
        end
      end
    end

    def update(message = "")
      self.text = "State: #{message}"
    end
  end
end
