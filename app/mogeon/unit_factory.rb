module Mogeon
  class UnitFactory
    def initialize
      @time_elapsed = 0
      @spawn_target = 0
      @creating = false
    end

    attr_accessor :creating

    def update(time_since_last)
      if @creating
        @time_elapsed += time_since_last
      else
        @time_elapsed = 0
      end
    end

    def character
      case @time_elapsed.to_i
      when 0
        puts "nothing"
        Friend
      when 1..10
        puts "1..10"
        Friend
      end
    end
  end
end
