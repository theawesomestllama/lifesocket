require_relative '../terrarium'

module LifeSocket
module Creature

class DrunkBug
  SYMBOL = :'~'

  def act(env)
    return {type: :move, direction: Terrarium::DIRECTIONS.keys.sample}
  end
end

end
end