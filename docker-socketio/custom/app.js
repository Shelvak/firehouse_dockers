var html = require('http')
  , app  = html.createServer()
  , io   = require('socket.io')(app, {origins: '*:*'});

app.listen(8085);

function SessionController () {
  this.redis = require('redis').createClient(
    6379, 
    process.env['REDIS_HOST']
  )
}

SessionController.prototype.subscribe = function (socket) {
  console.log('se llama a controller subscribe')
  this.redis.on('message', function (channel, msg) {
    console.log('en redis msg')
    socket.emit('new-console-intervention', { link: msg });
  });

  console.log('en redis subscribe')
  this.redis.subscribe('socketio-new-intervention');
}

SessionController.prototype.unsubscribe = function () {
  this.redis.unsubscribe('socketio-new-intervention');
}



io.on('connection', function (socket) {
  console.log('abriendo conexion')
  sessionController = new SessionController
  sessionController.subscribe(socket);

  console.log('subscripto')

  socket.on('new intervention', function (data) {
    console.log('new intervention, emitting')
    socket.broadcast.emit('update interventions', { message: data['message'] })
  });

  socket.on('disconnect', function() {
    console.log('desconecting')
    sessionController.unsubscribe()
  });
});
