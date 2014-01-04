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
        actions = effect_for(name)
        return unless actions

        action do
          actions
        end
      end

      def effect_for(name)
        case name
        when :selected
          # 選択中のアニメーション
          nil
        when :current
          # 現在移動を開始するユニット
          [
            SKAction.scaleBy(1.5, duration: 0.05 * SPEED),
            SKAction.scaleTo(self.class::SCALE, duration: 0.3 * SPEED),
          ]
        else
          puts "'#{name}' effect not found"
          nil
        end
      end
    end
  end
end
