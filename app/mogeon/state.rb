module Mogeon

  # TODO:
  #   State が変わった時に実行する処理を登録したい
  #   state = State.new
  #   state.register :changed => Proc.new
  class State
    System      = 'System'.freeze
    Player      = 'Player'.freeze
    Friend      = 'Friend'.freeze
    Enemy       = 'Enemy'.freeze
    Neutral     = 'Neutral'.freeze
    Environment = 'Environment'.freeze

    def initialize
      @state_changed = false
      @state = Player
    end

    def current
      @state
    end

    def set(state)
      @state_changed = true
      @state = state
    end

    def next
      next_state = case @state
                   when System      then Player
                   when Player      then Friend
                   when Friend      then Enemy
                   when Neutral     then Environment
                   when Environment then Player
                   else                  System
                   end
      @state_changed = true
      @state = next_state
    end

    def changed?
      if @state_changed
        @state_changed = false
        true
      else
        false
      end
    end
  end
end
