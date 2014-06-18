require_relative './terrarium'

require_relative './point'

module LifeSocket

class LifelikeTerrarium < Terrarium
  def initialize(width, height)
    super

    register_action :move, lambda { |grid, point, action|
      creature = grid[point]
      unless send(:class)::DIRECTIONS.has_key?(action[:direction])
        raise "Unsupported move direction: #{action[:direction]}"
      end
      to = point + send(:class)::DIRECTIONS[action[:direction]]
      if grid.inside?(to) and grid[to] == nil
        grid.move(point, to)
      end
      creature.respond_to?(:energy) and creature.energy -= 1
      break grid
    }

    register_action :wait, lambda { |grid, point, action|
      creature = grid[point]
      creature.energy and creature.energy -= 0.2
      break grid
    }

    register_action :eat, lambda { |grid, point, action|
      creature = grid[point]
      unless send(:class)::DIRECTIONS.has_key?(action[:direction])
        raise "Unsupported move (eat) direction: #{action[:direction]}"
      end
      to = point + send(:class)::DIRECTIONS[action[:direction]]
      meal = grid[to]
      if creature.respond_to?(:energy) and meal.respond_to?(:energy)
        #No check is made that meal.energy >= 0.
        #'Dead' creature are only removed at the end of a step.
        #It is possible to add an action that allows a creature to 'kill'
        #itself and leave it with negative energy, which would damage
        #and creature later attempting to eat it.
        creature.energy += meal.energy
        meal.energy = -1
      end
      break grid
    }

    register_action :photosynthesize, lambda { |grid, point, action|
      creature = grid[point]
      creature.energy += 1
      break grid
    }

    register_action :reproduce, lambda { |grid, point, action|
      creature = grid[point]
      unless send(:class)::DIRECTIONS.has_key?(action[:direction])
        raise "Unsupported move (eat) direction: #{action[:direction]}"
      end
      to = point + send(:class)::DIRECTIONS[action[:direction]]
      break grid unless grid[to].nil?
      if creature.respond_to?(:energy)
        baby = creature.class.new
        energy_cost = baby.energy * 2
        if creature.energy > energy_cost
          grid[to] = baby
        end
        creature.energy -= energy_cost
      end
      break grid
    }
  end

  def step
    super
    #Kill dead creature
    @grid.each_with_index { |element, point|
      @grid[point] = nil if element.respond_to?(:energy) and element.energy <= 0
    }
  end

end

end