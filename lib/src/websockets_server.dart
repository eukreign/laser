part of laser.server;

class WebSockets {
  
  LaserConfiguration _conf;
  HttpServer _server;
  List<WebSocket> _sockets = [];

  WebSockets(this._conf) {
    
  }

  Future start() {
    Future<HttpServer> future = HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 2014);
    future.then((HttpServer server) {
      server
        .transform(new WebSocketTransformer())
        .listen(add);
      _server = server;
    });
    return future;
  }

  void add(WebSocket ws) {
    _sockets.add(ws);
    ws.done.then((_) => _sockets.remove(ws));
  }
  
  void broadcast(Map message) {
    final m = JSON.encode(message);
    _sockets.forEach((s) => s.add(m));
  }

  Future stop() {
    return _server.close(force: true);
  }
}