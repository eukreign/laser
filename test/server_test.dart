library laser.test.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:unittest/unittest.dart';
import 'package:laser/server.dart';

class LaserServerTestConfiguration extends SimpleConfiguration {
  LaserTestServer _server;
  LaserServerTestConfiguration(this._server);
  void onDone(bool success) {
    super.onDone(success);
    _server.stop();
  }
}

main() {
  var conf = new LaserConfiguration.fromPath('test/test_config.yaml');
  var server = new LaserTestServer(conf);
  unittestConfiguration = new LaserServerTestConfiguration(server);

  Future ready = server.start();

  test('test file changed event', () {
    var response = new Completer<Map>();
    response.future.then(expectAsync((e) =>
      expect(e, containsValue('test/sample/sample_test.html'))
    ));
    ready.then((_) {
      WebSocket.connect("ws://localhost:${WEBSOCKET_PORT}").then((ws) {
        ws.listen((msg) {
          response.complete(JSON.decode(msg));
          ws.close();
        });
        new File('test/sample/sample.dart').writeAsString("");
      });
    });
  });


}