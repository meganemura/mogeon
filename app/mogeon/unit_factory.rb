module Mogeon
  class UnitFactory
    def initialize
      reset
    end

    def reset
      @time_elapsed = LONG_PRESS_EPOCH
      @spawn_target = 0
      @creating = false
    end

    attr_accessor :creating
    attr_accessor :create_at

    def update(time_since_last)
      if @creating
        @time_elapsed += time_since_last
      else
        reset
      end
    end

    def spawn?
      !! character
    end

    def character
      case @time_elapsed.to_i
      when 0
        nil
      when 1..10
        Friend
      end
    end
  end
end
