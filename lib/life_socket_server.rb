require 'rack'
require 'rack/handler/puma'

require_relative './web_socket_interface'

module LifeSocket

class LifeSocketServer
  def initialize(root)
    @root = root
  end
  def call(env)
    path = Rack::Utils.unescape(env['PATH_INFO'])
    path += 'index.html' if path[-1] == '/'

    #Default response
    response = [404, {'Content-Type' => 'text/html'}, ["Not found: #{path}"]]

    full_path = @root + path

    if File.exists?(full_path)
      mime = Rack::Mime.mime_type(File.extname(full_path))

      response = [200, {'Content-Type' => mime}, [File.read(full_path)]]
    end

    return response
  end

  def self.run(port = 9292)
    app = Rack::Builder.new do
      use WebSocketInterface
      root = File.expand_path(File.dirname(__FILE__)).split('/')[0..-2].join('/') + '/html'
      run LifeSocketServer.new(root)
    end

    Rack::Handler::Puma.run app, Port: port
  end
end

end

LifeSocket::LifeSocketServer.run if __FILE__==$0