part of laser.server;


abstract class TestRunnerInstance<T> {
  Stream<Map> get stream;
  void add(Map data);
}

class HeadlessTestRunner {
  Future<TestRunnerInstance> run(String test) {
    
    return new IsolateTestInstance(test).run();
  }
}

class IsolateTestRunner {

  Future<TestRunnerInstance> run(String test) {
    return new IsolateTestInstance(test).run();
  }

}

class IsolateTestInstance implements TestRunnerInstance {

  String _test_file;

  ReceivePort _receive;
  SendPort _send;

  final _controller = new StreamController<Map>();
  Stream<Map> get stream => _controller.stream;

  IsolateTestInstance(String this._test_file);

  void add(data) {
    _send.send(data);
  }

  Future<IsolateTestInstance> run() {
    _receive = new ReceivePort();
    var test = path.join(Directory.current.path, _test_file);
    Isolate.spawnUri(new Uri.file(test), [], _receive.sendPort);
    StreamSubscription subscription = _receive.listen(null);
    
    var completer = new Completer();
    subscription.onData((SendPort send) {
      _send = send;
      subscription.onData((data)=>_controller.add(data));
      completer.complete(this);
    });

    return completer.future;
  }
}

class WebSocketTestInstance implements TestRunnerInstance {
  WebSocket _websocket;
  Stream get stream => _websocket.map(JSON.decode);
  void add(data) => _websocket.add(JSON.encode(data));

  WebSocketTestInstance(this._websocket);
}

class IncomingWebTests {
  HttpServer _http;
  
  Stream<TestRunnerInstance> get stream => _controller.stream;
  final _controller = new StreamController<TestRunnerInstance>();

  IncomingWebTests();

  Future start() {
    Future<HttpServer> future = HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 2005);
    future.then((HttpServer http) {
      http
        .transform(new WebSocketTransformer())
        .listen((ws)=>_controller.add(new WebSocketTestInstance(ws)));
      _http = http;
    });
    return future;
  }

  Future stop() {
    return _http.close(force: true);
  }
}