module LifeSocket

class Point
  attr_accessor :x, :y

  def initialize(x,y)
    @x = x
    @y = y
  end

  def +(other)
    Point.new(@x + other.x, @y + other.y)
  end

  def -(other)
    Point.new(@x - other.x, @y - other.y)
  end

  def ==(other)
    @x == other.x and @y == other.y
  end

  def eql?(other)
    #Avoiding explicit self for Celluloid use later
    #Not sure if actually necessary
    #self == other
    send(:==, other)
  end

  def to_s
    "Point(#{@x}, #{@y}"
  end
end

end