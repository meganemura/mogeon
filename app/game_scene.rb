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

      @state = State.new
      setup_map
      setup_character
      setup_hud
    end

    def setup_map
      Map.size = self.frame.size
      Map.tiles.each { |tile| self << tile }
    end

    DEFAULT_FRIEND_SIZE = 2
    DEFAULT_ENEMY_SIZE  = 2
    def setup_character
      # setup friends
      @friends = DEFAULT_FRIEND_SIZE.times.map { Friend.new(0, 0) }
      @friends.each_with_index do |friend, i|
        # TODO: set friend to the map
        friend.locate(i, 0)
        self.addChild(friend)
      end

      # setup enemies
      @enemies = DEFAULT_ENEMY_SIZE.times.map { Enemy.new(0, 0) }
      @enemies.each_with_index do |enemy, i|
        # TODO: set enemy to the map
        enemy.locate(i, 7)
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
        config.position = CGPointMake(
          20 + config.frame.size.width / 2,
          self.size.height - (20 + config.frame.size.height)
        )
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
      end

      # 動いている Unit がなければ次の処理を行う
      # いい方法ではなさそう
      unless @unit_moving
        case @state.current
        when State::Friend
          move_one_friend
        when State::Enemy
          move_one_enemy
        end
      end
    end

    def move_one_friend
      x, y = Map.moving_amount(:up)
      friend = @friends.find { |friend| friend.active? }
      if friend
        @unit_moving = true
        done_action = SKAction.runBlock(lambda {@unit_moving = false})
        friend.move(x, y, done_action)
        friend.deactivate
      else
        @state.set(State::Enemy)
        @enemies.each { |enemy| enemy.activate }
        # activate enemy
      end
    end

    def move_one_enemy
      x, y = Map.moving_amount(:down)
      enemy = @enemies.find { |enemy| enemy.active? }
      if enemy
        @unit_moving = true
        done_action = SKAction.runBlock(lambda {@unit_moving = false})
        enemy.move(x, y, done_action)
        enemy.deactivate
      else
        @state.set(State::Player)
      end
    end

    def user_controllable?
      [State::Player].include?(@state.current)
    end

    # UISwipeGestureRecognizer
    def swipe(recognizer)
      return unless user_controllable?
      case recognizer.state
      when UIGestureRecognizerStateRecognized
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
      return if @tile_moving
      @tile_moving = true

      # スワイプの direction に合わせて nodes を移動させる
      x, y = Map.moving_amount(direction)
      target_nodes(touched_node, with: direction).each do |node|
        # TODO: nodes の数だけ実行されるのを1回に変更したい
        done_action = SKAction.runBlock(lambda {
          @tile_moving = false
          @friends.each { |friend| friend.activate }
          @state.set(State::Friend)
        })
        node.move(x, y, done_action)
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

      nodes = [Map.tiles, @friends, @enemies].flatten

      nodes.select do |tile|
        condition.call(tile.position, touched_at)
      end
    end

  end
end
