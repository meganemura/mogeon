class CGPoint

  def coerce(numeric)
    [self, numeric]
  end

  def ==(operand)
    CGPointEqualToPoint(self, operand)
  end

  def +@
    self
  end

  def -@
    CGPointMake(-x, -y)
  end

  [:+, :-, :*, :/].each do |operator|
    define_method operator do |operand|
      operation(operator, operand)
    end
  end


  private

  def operation(operator, operand)
    case operand
    when Numeric
      CGPointMake(x.send(operator, operand), y.send(operator, operand))
    when CGPoint
      CGPointMake(x.send(operator, operand.x), y.send(operator, operand.y))
    else
      operand.respond_to?(:to_point) && operation(operator, operand.to_point)
    end
  end

end
