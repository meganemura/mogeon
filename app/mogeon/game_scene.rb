module Mogeon
  class GameScene < SKScene

    include SceneHelper

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
      tap_recognizer.minimumPressDuration = LONG_PRESS_EPOCH
      self.view.addGestureRecognizer(tap_recognizer)
    end

    def create_scene_contents
      self.backgroundColor = SKColor.darkGrayColor

      @queue = []
      @state = State.new
      @world = GameWorld.new(self)
      @last_updated_at = 0
      @last_update_time_interval = 0
    end

    # Called before each frame is rendered
    def update(current_time)
      time_since_last_update = current_time - @last_updated_at
      # Handle time delta.
      # If we drop below 60fps, we still want everything to move the same distance.
      time_since_last = current_time - @last_update_time_interval

      # more than a second since last update
      if time_since_last > 1
        time_since_last = 1.0 / 60.0
      end

      update_with_time_since_last_update(time_since_last)
    end

    def update_with_time_since_last_update(time_since_last)
      if @state.changed?
        @world.state_hud.update(@state.current.to_s)
        queue_movers
      end

      @world.factory.update(time_since_last)
      if @world.factory.spawn?
        create_at = @world.factory.create_at
        tile = Map.tile_at(create_at.first, create_at.last)
        tile.texture = Tile.partial_texture(5, 6)
      end

      case @state.current
      when State::System
        # system action
        @state.next
      when State::Player
        # カウントダウン
        @last_update_time_interval += time_since_last
        if @last_update_time_interval > GameWorld::ENEMY_SPAWN_INTERVAL
          @last_update_time_interval = 0
          @state.next
        end
      else
        process_queue
      end
    end

    def game_cleared?
      Map.friends.size - Map.enemies.size >= 1
    end

    def transition_to_result
      one_time(:cleared) do
        @world.backgroundMusicPlayer.stop
        Map.clear!
        reveal = SKTransition.flipHorizontalWithDuration(0.5 * SPEED)
        result_scene = ResultScene.alloc.initWithSize(self.size)
        self.view.presentScene(result_scene, transition: reveal)
      end
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

      if game_cleared?
        transition_to_result
        return
      end

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
      touch_location  = recognizer.locationInView(recognizer.view)
      touch_location  = self.convertPointFromView(touch_location)
      touched_node    = self.nodeAtPoint(touch_location)

      case recognizer.state
      when UIGestureRecognizerStateBegan
        logging "UILongPress: UIGestureRecognizerStateBegan"
        @world.factory.creating = true
        @world.factory.create_at = [touched_node.x, touched_node.y]
      when UIGestureRecognizerStateChanged
        logging "UILongPress: UIGestureRecognizerStateChanged"
        @world.factory.creating = false
      when UIGestureRecognizerStateEnded
        logging "UILongPress: UIGestureRecognizerStateEnded"
        # !user_controllable? の場合の処理を検討
        character = @world.factory.character
        if character
          @world.spawn_friend(character, touched_node.x, touched_node.y)
        end
        @world.factory.creating = false

        tile = Map.tile_at(touched_node.x, touched_node.y)
        tile.texture = Tile.partial_texture(6, 6)
      end
    end

  end
end
