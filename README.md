# lifesocket

This is an implementation of chapter six of the
[first edition](http://www.amazon.com/dp/1593272820) of Eloquent JavaScript
by Marijn Haverbeke. The logic is run on a server and written in Ruby.
The client is written in JavaScript and uses the canvas element for
visualization. Client/server communication is implemented using WebSockets.

## Important

Almost exactly zero testing has been done. Development was done in Xubuntu
with Chromium 34 and Rubinius 2.2.7 in RVM.

## Setup

lifesocket depends on the rack, puma, and faye-websocket gems.

Install these gems with

```
$ bundle install
```

in the directory. Or

```
$ gem install rack puma faye-websocket
```

## Running

Start the server with

```
$ rackup -s puma -E production -p 9292
```

or 

```
$ ruby ./lib/life_socket_server.rb
```

and open [http://localhost:9292](http://localhost:9292) in a browser.
