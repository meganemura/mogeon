module Mogeon
  module Unit
    module Effectable

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
      end

      # エフェクトを実行する
      def effect(name)
        case name
        when :selected
          # 選択中のアニメーション
        when :current
          # 現在移動を開始するユニット
          action do
            [
              SKAction.scaleBy(1.5, duration: 0.05),
              SKAction.scaleTo(self.class::SCALE, duration: 0.3),
            ]
          end
        else
          puts "'#{name}' effect not found"
        end
      end
    end
  end
end
