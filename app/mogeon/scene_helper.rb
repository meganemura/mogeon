module Mogeon
  module SceneHelper

    # name をキーとして一回だけ実行する
    def one_time(name)
      return unless block_given?

      @one_time_variables ||= {}
      unless @one_time_variables[name]
        @one_time_variables[name] = true
        yield
      end
    end

    def logging(message)
      puts message.inspect
    end

  end
end
