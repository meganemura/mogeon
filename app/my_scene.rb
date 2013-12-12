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

  def createSceneContents

    self.backgroundColor = SKColor.darkGrayColor

    setup_map
    setup_character
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

  # XXX: Map class のインスタンスメソッドにしたい
  def locate(character)
    character.setPosition(CGPointMake(0, 0))
    self << character
  end

  def update(current_time)
    # Called before each frame is rendered
  end

  # UISwipeGestureRecognizer
  def swipe(recognizer)
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

  def moving_amount(direction)
    case direction
    when :right
      [Tile::SIZE, 0]
    when :left
      [-Tile::SIZE, 0]
    when :up
      [0, Tile::SIZE]
    when :down
      [0, -Tile::SIZE]
    end
  end

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
    moving_nodes = Map.tiles.select do |tile|
      condition.call(tile.position, touched_at)
    end

    x, y = moving_amount(direction)
    moving_nodes.each do |node|
      node_at = node.position

      new_x = node_at.x + x
      new_y = node_at.y + y

      if new_x < 0
        new_x += Map.width
      elsif new_x >= Map.width
        new_x -= Map.width
      end

      if new_y < 0
        new_y += Map.height
      elsif new_y >= Map.height
        new_y -= Map.height
      end

      node.setPosition(CGPointMake(new_x, new_y))
    end
  end

end
end
