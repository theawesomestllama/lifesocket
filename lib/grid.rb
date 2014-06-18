require_relative './point'

module LifeSocket

class Grid
  include Enumerable

  attr_reader :width, :height

  def initialize(width, height, contents=nil)
    @contents = contents if contents.respond_to?(:each)
    @contents ||= Array.new(width * height, contents)
    raise 'Grid contents do not fit grid size' unless @contents.size == width*height

    @width = width
    @height = height
  end

  def each(&block)
    @contents.each {|element| block.call(element)}
  end

  def each_with_index(&block)
    @contents.each_with_index {|element, index| block.call(element,
                                                           Point.new(index % @width,
                                                                     index / @width))}
  end

  def [](point)
    raise '#{point} not in grid.' unless inside?(point)
    return @contents[point.x + @width*point.y]
  end

  def []=(point,val)
    raise '#{point} not in grid.' unless inside?(point)
    @contents[point.x + @width*point.y] = val
  end

  def inside?(point)
    point.x >= 0 and point.x < @width and point.y >= 0 and point.y < @height ? true : false
  end

  def move(from, to)
    #Avoiding explicit self for Celluloid use later
    #Not sure if actually necessary
    #self[to] = self[from]
    #self[from] = nil
    send(:[]=, to, send(:[], from))
    send(:[]=, from, nil)
  end

  attr_accessor :contents
  private :contents
end

end