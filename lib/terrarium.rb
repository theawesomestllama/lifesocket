require_relative './grid'
require_relative './point'

module LifeSocket

class Terrarium
  DIRECTIONS = {
    n: Point.new(0, -1),
    ne: Point.new(1, -1),
    e: Point.new(1, 0),
    se: Point.new(1, 1),
    s: Point.new(0, 1),
    sw: Point.new(-1, 1),
    w: Point.new(-1, 0),
    nw: Point.new(-1, -1)
  }

  DIRECTIONS.define_singleton_method(:opposite) do |dir|
    case dir
      when :n
        :s
      when :ne
        :sw
      when :e
        :w
      when :se
        :nw
      when :s
        :n
      when :sw
        :ne
      when :w
        :e
      when :nw
        :se
    end
  end

  def initialize(width, height)
    @grid = LifeSocket::Grid.new(width, height, nil)
    @element_registry = {}
    @action_registry = {}

    #Default actions
    register_action :move, lambda { |grid, point, action|
      creature = grid[point]
      unless send(:class)::DIRECTIONS.has_key?(action[:direction])
        raise "Unsupported move direction: #{action[:direction]}"
      end
      to = point + send(:class)::DIRECTIONS[action[:direction]]
      if grid.inside?(to) and grid[to] == nil
        grid.move(point, to)
      end
      break grid
    }

    register_action :wait, lambda { |grid, point, action|
      break grid
    }
  end

  def from_s(string)
    grid = []
    string.each_char do |char|
      if char == "\n"
        next #Ignore newlines
      elsif char == ' '
        grid << nil
      elsif char == '#'
        grid << :wall
      elsif element_registry.has_key?(char.intern)
        grid << element_registry[char.intern].new
      else
        raise "Character '#{char}' not registered with this terrarium."
      end
    end
    load_array(grid)
  end

  alias_method :load_string, :from_s

  def register_action(type, action)
    unless action.arity == 3
      raise "Incompatible action '#{type}'. Actions must take a grid, a point, and an action hash."
    end
    action_registry[type] = action
    puts "Registered #{type}: #{action}"
  end

  def register_actions(*actions)
    actions.each { |action|
      type = action.keys[0]
      register_action(type, action[type])
    }
  end

  def register_creature(creature_class)
    element_registry[creature_class::SYMBOL] = creature_class
  end

  def register_creatures(*creature_classes)
    creature_classes.each {|creature_class| register_creature(creature_class)}
  end

  def count(creature_class)
    creature_class = case creature_class
      when  Symbol
        element_registry[creature_class]
      when String
        element_registry[creature_class.intern]
      else
        creature_class
    end
    @grid.inject(0) { |count, element| creature_class === element ? count + 1 : count }
  end

  def randomize
    characters = @element_registry.inject(['#', ' ']) {|chars, pair| chars << pair[0].to_s}

    string = Array.new(@grid.width * @grid.height).map { characters.sample }.join('')
    from_s(string)
  end

  def step
    acting_creatures.each do |creature, point|
      process_creature(creature, point)
    end
  end

  def to_s
    string = @grid.map {|element| get_character(element)}.join('')
    #Add newlines
    (@grid.height - 1).times do |line|
      string.insert(@grid.width * (line + 1) + line, "\n")
    end
    string
  end

  ####################################################
  #PRIVATE INTERFACE
  ####################################################

  private

  attr_reader :grid

  attr_reader :element_registry

  attr_reader :action_registry

  def [](point)
    @grid[point]
  end

  def []=(point, element)
    @grid[point] = element
  end

  def inside?(point)
    @grid.inside?(point)
  end

  def get_character(element)
    case element
      when nil
        ' '
      when :wall
        '#'
      else
        element.class::SYMBOL.to_s
    end
  end

  def get_environment(point)
    env = {}
    #TODO: Replacing the braces with do/end breaks this. Why?
    send(:class)::DIRECTIONS.each { |sym, direction|
      other = point + direction
      element = inside?(other) ? send(:[], point + direction) : :wall
      env[sym] = get_character(element)
    }
    env
  end

  def process_creature(creature, point)
    action = creature.act(get_environment(point))
    unless action_registry.has_key?(action[:type])
      raise "Unsupported action: #{action[:type]}"
    end

    @grid = action_registry[action[:type]].call(@grid, point, action)
  end

  def load_array(grid)
    @grid = LifeSocket::Grid.new(@grid.width, @grid.height, grid)
  end

  def acting_creatures
    creatures = []
    #TODO: Replacing the braces with do/end breaks this. Why?
    @grid.each_with_index { |element, point|
      creatures << [element, point] if element.respond_to?(:act)
    }
    creatures
  end

end

end