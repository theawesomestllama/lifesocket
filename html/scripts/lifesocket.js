var LifeSocketClient = function (target) {
  "use strict";
  this.target = target;
  this.width = this.height = 0;
  this.state = '';

  this.registry = {
    '#': "rgb(0,0,0)",
    ' ': "rgb(255,255,255)",
    '*': "rgb(0,255,0)",
    'c': "rgb(255,0,0)"
  };
};

LifeSocketClient.prototype.onopen = function () {
  "use strict";
  debug("Socket open.");
};

LifeSocketClient.prototype.onclose = function () {
  "use strict";
  debug("Socket closed.");
};

LifeSocketClient.prototype.onmessage = function (evt) {
  "use strict";
  debug("RECEIVED: " + evt.data);

  var onpoststate = function (message) {
    this.state = message.state;
  };

  try {
    var message = JSON.parse(evt.data);
  } catch(e) {
    debug("PARSING ERROR: ", e);
  }

  switch (message.type) {
    case 'POST_STATE':
      onpoststate.bind(this)(message);
      break;
    case 'STEP_OK':
      break;
    case 'INITIALIZED':
      this.width = message.width;
      this.height = message.height;
      break;
    default:
      debug("UNKNOWN MESSAGE TYPE: " + evt.data);
  }
};

LifeSocketClient.prototype.onerror = function (evt) {
  "use strict";
  debug("ERROR: " + evt.data);
};

LifeSocketClient.prototype.open = function (uri) {
  "use strict";
  var ws = new WebSocket(uri);

  ws.onopen = this.onopen.bind(this);
  ws.onclose = this.onclose.bind(this);
  ws.onmessage = this.onmessage.bind(this);
  ws.onerror = this.onerror.bind(this);

  this.ws = ws;
};

LifeSocketClient.prototype.close = function () {
  "use strict";
  this.ws.close();
};

LifeSocketClient.prototype.send = function (msg) {
  "use strict";
  var message = JSON.stringify(msg);
  debug("SENT: " + message);
  this.ws.send(message);
};

LifeSocketClient.prototype.requestState = function () {
  "use strict";
  this.send({
    type: "GET_STATE"
  });
};

LifeSocketClient.prototype.initialize = function (width, height) {
  "use strict";
  this.send({
    type: "INITIALIZE",
    width: width,
    height: height
  });
};

LifeSocketClient.prototype.step = function () {
  "use strict";
  this.send({
    type: "STEP"
  });
};

LifeSocketClient.prototype.draw = function () {
  "use strict";
  if (this.width === 0 || this.height === 0) {
    return;
  }

  var c = this.target.getContext("2d");

  var target_width = this.target.clientWidth;
  var target_height = this.target.clientHeight;

  var cell_width = target_width / this.width;
  var cell_height = target_height / this.height;

  c.clearRect(0, 0, target_width, target_height);

  for(var index = 0; index < this.state.length; index++) {
    var color = this.registry[this.state[index]];
    var x =  index % this.width * cell_width;
    var y = Math.floor(index / this.width) * cell_height;
    c.fillStyle = color;
    c.fillRect(x, y, cell_width, cell_height);
  }
};