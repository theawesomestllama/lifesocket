require_relative './lichen_eater'

module LifeSocket
module Creature

class CleverLichenEater < LichenEater
  #Uses SYMBOL, energy, and initialize from LichenEater

  def initialize
    super
    @dir = :ne
  end

  def act(env)
    empty_spaces = env.select {|dir, element| element == ' '}.keys
    lichen_spaces = env.select {|dir, element| element == '*'}.keys

    @dir = empty_spaces.sample unless [' ', '*'].include?(env[@dir])

    if @energy >= 30 and empty_spaces.size > 0
      {type: :reproduce, direction: empty_spaces.sample}
    elsif lichen_spaces.size > 1 or (lichen_spaces == 1 and @energy <= 1)
      {type: :eat, direction: lichen_spaces.sample}
    elsif empty_spaces.size > 0
      {type: :move, direction: @dir}
    else
      {type: :wait}
    end
  end
end

end
end