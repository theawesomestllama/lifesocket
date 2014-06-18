require 'faye/websocket'

require 'json'

require_relative 'lifelike_terrarium'
require_relative 'creature/clever_lichen_eater'
require_relative 'creature/lichen'

module LifeSocket

class WebSocketInterface
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless Faye::WebSocket.websocket?(env)

    ws = Faye::WebSocket.new(env)

    terrarium = LifeSocket::LifelikeTerrarium.new(0,0)

    ws.on :message do |e|
      begin
        message = JSON.parse(e.data)
        case message['type']
          when 'INITIALIZE'
            width = message['width'] || 80
            height = message['height'] || 60
            terrarium = LifeSocket::LifelikeTerrarium.new(width, height)
            terrarium.register_creatures LifeSocket::Creature::Lichen, LifeSocket::Creature::CleverLichenEater
            terrarium.randomize
            response = {
                type: :INITIALIZED,
                width: width,
                height: height
            }
          when 'STEP'
            steps = message['num_steps'] || 1
            steps.times {terrarium.step}
            response = {
                type: :STEP_OK,
                num_steps: steps
            }
          when 'GET_STATE'
            response = {
                type: :POST_STATE,
                state: terrarium.to_s
            }
          else
            response = {
                type: :ERROR,
                description: 'Unknown Message Type',
                details: message['type']
            }
        end
      rescue JSON::ParserError
        response = {
            type: :ERROR,
            description: "Malformed JSON",
            details: e.data
        }
      end
      ws.send(response.to_json)
    end

    ws.on :close do |e|
      ws = nil
    end

    return ws.rack_response
  end
end

end