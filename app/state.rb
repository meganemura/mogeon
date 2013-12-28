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
      @states = {
        System      => 0,
        Player      => 0,
        Friend      => 0,
        Enemy       => 0,
        Neutral     => 0,
        Environment => 0,
      }
      @state = Player
    end

    def current
      @state
    end

    def set(state)
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
      @state = next_state
    end
  end
end
