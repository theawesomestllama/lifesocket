require_relative '../terrarium'

module LifeSocket
module Creature

class BouncingBug
  SYMBOL = :'%'

  def initialize(dir=:ne)
    @dir = dir
  end

  def act(env)
    @dir = if env[Terrarium::DIRECTIONS[:@dir]] == ' '
      @dir
    else
      Terrarium::DIRECTIONS.opposite(@dir)
    end
    return {type: :move, direction: @dir}
  end
end

end
end