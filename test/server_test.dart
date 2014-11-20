library laser.test.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:unittest/unittest.dart';
import 'package:laser/server.dart';

class LaserServerTestConfiguration extends SimpleConfiguration {
  LaserServer _server;
  LaserServerTestConfiguration(this._server);
  void onDone(bool success) {
    super.onDone(success);
    _server.stop();
    exit(0);
  }
}

main() {
  var conf = new LaserConfiguration.fromPath('test/test_config.yaml');
  var server = new LaserServer(conf);
  unittestConfiguration = new LaserServerTestConfiguration(server);

  server.start().then((_) {

    test('test file changed event', () {
      var response = new Completer<Map>();
      response.future.then(expectAsync((e) =>
        expect(e, containsValue('test/sample/sample_test.html'))
      ));
      WebSocket.connect("ws://localhost:2014").then((ws) {
        ws.listen((msg) {
          response.complete(JSON.decode(msg));
          ws.close();
        });
        new File('test/sample/sample.dart').writeAsString("");
      });
    });

  });
}