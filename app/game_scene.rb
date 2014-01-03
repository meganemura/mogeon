module Mogeon
  class GameScene < SKScene

    def initWithSize(size)
      super
      self
    end

    def didMoveToView(view)
      if !@contentCreated
        self.createSceneContents
        @contentCreated = true
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

    def createSceneContents
      self.backgroundColor = SKColor.darkGrayColor

      @queue = []
      @state = State.new
      setup_map
      setup_units
      setup_hud
    end

    def setup_map
      Map.size = self.frame.size
      Map.tiles.each { |tile| self << tile }
    end

    DEFAULT_FRIEND_SIZE = 2
    DEFAULT_ENEMY_SIZE  = 2
    def setup_units
      # setup friends
      DEFAULT_FRIEND_SIZE.times do
        friend = Friend.new(0, 0)
        x, y = Map.space(nil, 0)
        friend.locate(x, y)

        Map.friends << friend
        self.addChild(friend)
      end

      # setup enemies
      DEFAULT_ENEMY_SIZE.times do
        enemy = Enemy.new(0, 0)
        x, y = Map.space(nil, Map.rows - 1)
        enemy.locate(x, y)

        Map.enemies << enemy
        self.addChild(enemy)
      end

      # setup neutrals
    end

    STATE_HUD_NAME = 'state_hud'.freeze
    def setup_hud
      score_label = SKLabelNode.labelNodeWithFontNamed("Courier").tap do |config|
        config.name = STATE_HUD_NAME
        config.fontSize = 15
        config.fontColor = SKColor.greenColor
        config.text = "State: #{@state.current}"
        config.position = [
          20 + config.frame.size.width / 2,
          self.size.height - (20 + config.frame.size.height)
        ].to_point
      end
      self.addChild(score_label)
    end

    def update_hud
      state_hud = self.childNodeWithName(STATE_HUD_NAME)
      state_hud.text = "State: #{@state.current}"
    end

    # Called before each frame is rendered
    def update(current_time)

      if @old_state != @state.current
        @old_state = @state.current
        update_hud
        queue_movers
      end

      case @state.current
      when State::System
        # system action
        @state.next
      when State::Player
        # noop?
      else
        process_queue
      end
    end

    def queue_movers
      case @state.current
      when State::System
        setup_units
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
        after_x, after_y = @current_object.move_by(dx, dy) do
          # TODO: defeated が存在する場合には defeated 側に @current_object = nil をセットする
          SKAction.runBlock(lambda { @current_object = nil })
        end

        if defeated = Map.movers.find { |mover| mover.object_id != @current_object.object_id && mover.x == after_x && mover.y == after_y }
          Map.friends.delete(defeated)
          Map.enemies.delete(defeated)
          # FIXME: 本来消すべきではない
          #        (queue に入っている == 同族) のため
          #        think_moving で同じ種類の場所に移動しないようにするべき
          @queue.delete(defeated)

          defeated.action do
            [
              SKAction.playSoundFileNamed("kill1.mp3", waitForCompletion: false),
              SKAction.scaleXBy(0.1, y: 0.1, duration: 0.5),
              SKAction.runBlock(lambda {
                # TODO: 明らかに管理方法がおかしい
                #       Map.<<, Map.delete で全てできるようにする?
                self.removeChild(defeated)
              }),
            ]
          end
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

      case recognizer.state
      when UIGestureRecognizerStateBegan
        logging "UILongPress: UIGestureRecognizerStateBegan"

        sequence = SKAction.sequence([
          SKAction.rotateByAngle(degrees_to_radians(-4.0), duration: 0.1),
          SKAction.rotateByAngle(0.0, duration: 0.1),
          SKAction.rotateByAngle(degrees_to_radians(4.0), duration: 0.1),
        ])
        touched_node.with_nodes_of_sight.each do |node|
          node.runAction(SKAction.repeatActionForever(sequence))
        end
      when UIGestureRecognizerStateChanged
        logging "UILongPress: UIGestureRecognizerStateChanged"

        touched_node.with_nodes_of_sight.each do |node|
          stop_motion(node)
        end
      when UIGestureRecognizerStateEnded
        logging "UILongPress: UIGestureRecognizerStateEnded"

        touched_node.with_nodes_of_sight.each do |node|
          stop_motion(node)
        end
      end
    end

    def stop_motion(node)
      node.removeAllActions
      sequence = SKAction.sequence([
        SKAction.rotateToAngle(degrees_to_radians(0), duration: 0.1),
      ])
      node.runAction(SKAction.repeatActionForever(sequence))
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

    def swipe_node(touch_location, direction)
      touched_node = self.nodeAtPoint(touch_location)
      return unless touched_node.is_a? SKSpriteNode

      # スワイプの direction に合わせて nodes を移動させる
      dx, dy = Map.moving_amount(direction)
      target_nodes(touched_node, with: direction).each do |node|
        # TODO: nodes の数だけ実行されるのを1回に変更したい
        #       タッチ位置のユニットに対して行動する
        #       複数あった場合は?

        node.move_by(dx, dy) do
          [
            SKAction.playSoundFileNamed("chat.mp3", waitForCompletion: false),
            SKAction.runBlock(lambda {
              @state.set(State::Friend)
            }),
          ]
        end
      end
    end


    # タッチされた node と、スワイプ方向から移動する nodes を選ぶ
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
  end
end
