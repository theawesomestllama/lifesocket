require './lib/life_socket_server'
require './lib/web_socket_interface'

use LifeSocket::WebSocketInterface
run LifeSocket::LifeSocketServer.new(File.expand_path(File.dirname(__FILE__)) + '/html')
