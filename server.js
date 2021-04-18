/**
 * Code mostly copied from @noisyneuron https://github.com/noisyneuron/wekOsc
 */

var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);
var osc = require('osc-min');
var dgram = require('dgram');

var remoteIp = '127.0.0.1';
var remotePort = 3333; // set wekinator to listen to port 3333
var udp = dgram.createSocket('udp4');

/*
 using ip 192.168.1.150 .. change this for your setup
  in this file as well as index.html
  if you're using your browser locally this can be set to localhost
 */

server.listen(3000);

sendHeartbeat = function(arr) {
  var buf;
  var argsArr = [];
  for (let i = 0; i < 51; i++) {
    coord = arr[i];
    argsArr.push({type: "float", value: coord});
  }
  console.log(argsArr);
  buf = osc.toBuffer({
    address: "/wek/inputs",
    args: argsArr
  });
  return udp.send(buf, 0, buf.length, remotePort, "localhost");
};

app.get('/', function (req, res) {
  res.sendFile(__dirname + '/index.html');
});

app.get('/poses.js', function (req, res) {
  res.sendFile(__dirname + '/poses.js');
});

io.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('singlePose', function (data) {
    console.log(data);
    sendHeartbeat(data);
  });
});


