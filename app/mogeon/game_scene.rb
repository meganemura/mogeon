module Mogeon
  class GameScene < SKScene

    def initWithSize(size)
      super
      self
    end

    # Called immediately after a scene is presented by a view.
    def didMoveToView(view)
      one_time(:create_contents) do
        self.create_scene_contents
      end
      setup_gesture_recognizer
    end

    def setup_gesture_recognizer
      tap_recognizer = UILongPressGestureRecognizer.alloc.initWithTarget(self, action: :'long_press:')
      self.view.addGestureRecognizer(tap_recognizer)

      [
        UISwipeGestureRecognizerDirectionRight,
        UISwipeGestureRecognizerDirectionLeft,
        UISwipeGestureRecognizerDirectionUp,
        UISwipeGestureRecognizerDirectionDown,
      ].each do |direction|
        swipe_recognizer = UISwipeGestureRecognizer.alloc.initWithTarget(self, action: 'swipe:')
        swipe_recognizer.direction = direction
        self.view.addGestureRecognizer(swipe_recognizer)
      end
    end

    def create_scene_contents
      self.backgroundColor = SKColor.darkGrayColor

      @queue = []
      @state = State.new
      @world = GameWorld.new(self)
    end

    def update_hud
      state_hud = self.childNodeWithName(StateHud::NAME)
      state_hud.update(@state.current.to_s)
    end

    # Called before each frame is rendered
    def update(current_time)

      if @state.changed?
        update_hud
        queue_movers
      end

      case @state.current
      when State::System
        # system action
        if game_cleared? && !@in_transition
          @in_transition = true
          @world.backgroundMusicPlayer.stop
          Map.clear!
          reveal = SKTransition.flipHorizontalWithDuration(0.5 * SPEED)
          score_scene = ScoreScene.alloc.initWithSize(self.size)
          self.view.presentScene(score_scene, transition: reveal)
        else
          @state.next
        end
      when State::Player
        # noop?
      else
        process_queue
      end
    end

    def game_cleared?
      Map.friends.size - Map.enemies.size >= 1
    end

    def queue_movers
      case @state.current
      when State::System
        @world.setup_units
      when State::Friend
        @queue += Map.friends.sort {|a, b| b.y <=> a.y }  # y の降順
      when State::Enemy
        @queue += Map.enemies.sort {|a, b| a.y <=> b.y }  # y の昇順
      end
    end

    def process_queue
      return if processing?

      if @current_object = @queue.shift
        dx, dy = @current_object.think_moving

        # TODO: AI によって行動を決めるようにしたい
        moved_x, moved_y = @current_object.moved_point(dx, dy)

        @current_object.actions << [
          Effect.balloon(@current_object.class::SCALE),
          @current_object.move_to(moved_x, moved_y),
          # TODO: defeated が存在する場合には defeated 側に @current_object = nil をセットする
          SKAction.runBlock(lambda { @current_object = nil }),
        ]
        @current_object.run_actions

        defeated = Map.movers.find do |mover|
          mover.object_id != @current_object.object_id && mover.x == moved_x && mover.y == moved_y
        end

        if defeated
          Map.friends.delete(defeated)
          Map.enemies.delete(defeated)
          # FIXME: 本来消すべきではない
          #        (queue に入っている == 同族) のため
          #        think_moving で同じ種類の場所に移動しないようにするべき
          @queue.delete(defeated)

          defeated.actions << [
            SoundEffect.defeat,
            SKAction.scaleXBy(0.1, y: 0.1, duration: 0.5 * SPEED),
            SKAction.runBlock(lambda {
              # TODO: 明らかに管理方法がおかしい
              #       Map.<<, Map.delete で全てできるようにする?
              self.removeChild(defeated)
            }),
          ]
          defeated.run_actions
        end
      elsif @queue.empty?
        @state.next
      end
    end

    def processing?
      !! @current_object
    end

    def user_controllable?
      [State::Player].include?(@state.current)
    end


    # UILongPressGestureRecognizer
    def long_press(recognizer)
      return unless user_controllable?

      touch_location  = recognizer.locationInView(recognizer.view)
      touch_location  = self.convertPointFromView(touch_location)
      touched_node    = self.nodeAtPoint(touch_location)

      return unless touched_node.respond_to?(:sight)

      case recognizer.state
      when UIGestureRecognizerStateBegan
        logging "UILongPress: UIGestureRecognizerStateBegan"

        sequence = SKAction.sequence([
          SKAction.rotateByAngle(degrees_to_radians(-4.0), duration: 0.1 * SPEED),
          SKAction.rotateByAngle(0.0, duration: 0.1 * SPEED),
          SKAction.rotateByAngle(degrees_to_radians(4.0), duration: 0.1 * SPEED),
        ])
        touched_node.with_nodes_of_sight.each do |node|
          node.runAction(SKAction.repeatActionForever(sequence))
        end
      when UIGestureRecognizerStateChanged
        logging "UILongPress: UIGestureRecognizerStateChanged"

        touched_node.with_nodes_of_sight.each do |node|
          node.stop_motion.run_actions
        end
      when UIGestureRecognizerStateEnded
        logging "UILongPress: UIGestureRecognizerStateEnded"

        touched_node.with_nodes_of_sight.each do |node|
          node.stop_motion.run_actions
        end
      end
    end

    # UISwipeGestureRecognizer
    def swipe(recognizer)
      return unless user_controllable?

      case recognizer.state
      when UIGestureRecognizerStateRecognized
        logging "UISwipe: UIGestureRecognizerStateRecognized"
        touch_location = recognizer.locationInView(recognizer.view)
        touch_location = self.convertPointFromView(touch_location)
        direction = DIRECTION_MAP[recognizer.direction]
        self.swipe_node(touch_location, direction)
      end
    end

    DIRECTION_MAP = {
      (1 << 0) => :right,
      (1 << 1) => :left,
      (1 << 2) => :up,
      (1 << 3) => :down,
    }

    # Swipe 場所と方向から全対象のユニットを動かす
    def swipe_node(touch_location, direction)
      touched_node = self.nodeAtPoint(touch_location)
      return unless touched_node.is_a? SKSpriteNode

      # スワイプの direction に合わせて nodes を移動させる
      dx, dy = Map.moving_amount(direction)
      target_nodes(touched_node, with: direction).each do |node|
        # TODO: nodes の数だけ実行されるのを1回に変更したい
        #       タッチ位置のユニットに対して行動する
        #       複数あった場合は?
        node.actions << [
          node.move_by(dx, dy),
          SoundEffect.move_tiles,
          SKAction.runBlock(lambda { @state.set(State::Friend) }),
        ]
        node.run_actions
      end
    end


    # タッチされた node と、スワイプ方向から移動する nodes を選ぶ
    # TODO: Map.node_at / @world.node_at にしたい
    def target_nodes(touched_node, with: direction)
      condition = case direction
                  when :right, :left
                    lambda {|a, b| a.y == b.y }
                  when :up, :down
                    lambda {|a, b| a.x == b.x }
                  end

      touched_at = touched_node.position

      nodes = [Map.tiles, Map.friends, Map.enemies].flatten

      nodes.select do |tile|
        condition.call(tile.position, touched_at)
      end
    end

    def logging(message)
      puts message.inspect
    end

    # name をキーとして一回だけ実行する
    def one_time(name)
      return unless block_given?

      @one_time_variables ||= {}
      unless @one_time_variables[name]
        @one_time_variables[name] = true
        yield
      end
    end
  end
end
