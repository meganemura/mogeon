module Mogeon
  module Unit
    module Thinkable

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def think_moving(method_name)
          alias_method :think_moving, method_name
        end
      end

      # 周囲8マスに対して攻撃する
      def attack_to_near_around
        attack_target = sight.find do |point|
          Map.movers.find { |mover| mover.class != self.class && mover.x == point.first && mover.y == point.last }
        end

        if attack_target
          [attack_target.first - x, attack_target.last - y]
        else
          # 移動可能な場所を探す
          movable_points = default_moves
          Map.movers.each do |mover|
            movable_points.delete([mover.x, mover.y])
          end
          point = movable_points.first

          [point.first - x, point.last - y]
        end
      end
    end
  end
end
