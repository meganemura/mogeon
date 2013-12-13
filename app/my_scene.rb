module Mogeon
class MyScene < SKScene
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

  module State
    Player      = 'Player'.freeze
    Friend      = 'Friend'.freeze
    Enemy       = 'Enemy'.freeze
    Neutral     = 'Neutral'.freeze
    Environment = 'Environment'.freeze
  end

  def createSceneContents
    self.backgroundColor = SKColor.darkGrayColor

    @state = State::Player
    setup_map
    setup_character
    setup_hud
  end

  def setup_map
    Map.size = self.frame.size
    Map.tiles.each { |tile| self << tile }
  end

  DEFAULT_FRIEND_SIZE = 1
  def setup_character
    # setup friends
    @friends = DEFAULT_FRIEND_SIZE.times.map { Friend.new(0, 0) }
    @friends.each do |friend|
      locate(friend)
    end

    # setup enemies

    # setup neutrals
  end

  # TODO: locate は friends を Map の座標で設定する
  #       Friend#locate にしたい
  #       addChild は MyScene で行う
  def locate(character)
    # FIXME
    character.setPosition(CGPointMake(0, 0))
    self << character
  end

  STATE_HUD_NAME = 'state_hud'.freeze
  def setup_hud
    score_label = SKLabelNode.labelNodeWithFontNamed("Courier").tap do |config|
      config.name = STATE_HUD_NAME
      config.fontSize = 15
      config.fontColor = SKColor.greenColor
      config.text = "State: #{@state}"
      config.position = CGPointMake(
        20 + config.frame.size.width / 2,
        self.size.height - (20 + config.frame.size.height)
      )
    end
    self.addChild(score_label)
  end
  def update_hud
    state_hud = self.childNodeWithName(STATE_HUD_NAME)
    state_hud.text = "State: #{@state}"
  end

  # Called before each frame is rendered
  def update(current_time)

    # TODO: update hud when state changed
    if @old_state != @state
      @old_state = @state
      update_hud
    end

  end

  def user_controllable?
    [State::Player].include?(@state)
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
    @state = State::Friend
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

    condition = case direction
                when :right, :left
                  lambda {|a, b| a.y == b.y }
                when :up, :down
                  lambda {|a, b| a.x == b.x }
                end

    touched_at = touched_node.position
    nodes = [Map.tiles, @friends].flatten
    moving_nodes = nodes.select do |tile|
      condition.call(tile.position, touched_at)
    end

    x, y = moving_amount(direction)

    moving_nodes.each do |node|
      node_at = node.position

      new_x = round(node_at.x + x, Map.width)
      new_y = round(node_at.y + y, Map.height)

      node.setPosition(CGPointMake(new_x, new_y))
    end
  end

  def moving_amount(direction)
    case direction
    when :right
      [Tile::SIZE,  0]
    when :left
      [-Tile::SIZE, 0]
    when :up
      [0,  Tile::SIZE]
    when :down
      [0, -Tile::SIZE]
    end
  end

  def round(size, max)
    if size < 0
      size + max
    elsif max <= size
      size - max
    else
      size
    end
  end

end
end
