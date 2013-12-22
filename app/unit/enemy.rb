module Mogeon
  class Enemy < Unit

    REAL_SIZE = 32
    SCALE = 2.0
    TEXTURE = "bat"

    def think_moving
      [0, -1]
    end

  end
end
