module LifeSocket
module Creature

class StupidBug
  SYMBOL = :o

  def act(env)
    return {type: :move, direction: :s}
  end
end

end
end