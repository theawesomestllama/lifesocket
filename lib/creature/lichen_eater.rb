module LifeSocket
module Creature

class LichenEater
  SYMBOL = :'c'

  attr_accessor :energy

  def initialize
    @energy = 10
  end

  def act(env)
    empty_spaces = env.select {|dir, element| element == ' '}.keys
    lichen_spaces = env.select {|dir, element| element == 'c'}.keys

    if @energy >= 30 and empty_spaces.size > 0
      return {type: :reproduce, direction: empty_spaces.sample}
    elsif lichen_spaces.size > 0
      return {type: :eat, direction: lichen_spaces.sample}
    elsif empty_spaces.size > 0
      return {type: :move, direction: empty_spaces.sample}
    else
      return {type: :wait}
    end
  end
end

end
end