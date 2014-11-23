part of laser.server;


class LaserChrome {

  HttpServer _http;
  List<WebSocket> _sockets = [];

  LaserChrome();

  Future start() {
    Future<HttpServer> future = HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 2009);
    future.then((HttpServer http) {
      http
        .transform(new WebSocketTransformer())
        .listen(add);
      _http = http;
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
    return _http.close(force: true);
  }

}