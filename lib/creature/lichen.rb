module LifeSocket
module Creature

class Lichen
  SYMBOL = :'*'

  attr_accessor :energy

  def initialize
    @energy = 5
  end

  def act(env)
    empty_spaces = env.select {|dir, element| element == ' '}.keys

    if @energy >= 13 and empty_spaces.size > 0
      return {type: :reproduce, direction: empty_spaces.sample}
    elsif @energy < 20
      return {type: :photosynthesize}
    else
      return {type: :wait}
    end
  end
end

end
end