library laser.unittest;

import 'dart:html';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

import 'package:unittest/unittest.dart';
export 'package:unittest/unittest.dart';

part 'src/unittest_configuration.dart';

class WebSocketConnection implements LaserConnection {
  
  WebSocket _ws;

  WebSocketConnection() {
    _ws = new WebSocket('ws://localhost:2005');
  }

  Future get ready => _ws.onOpen.first;

  void send(message) {
    _ws.send(JSON.encode(message));
  }

  StreamSubscription listen(onData(Map data)) {
    return _ws.onMessage.listen((MessageEvent event) {
      onData(JSON.decode(event.data));
    });
  }

}

void laser() {
  groupSep = GROUP_SEP;
  LaserConnection laser = new WebSocketConnection();
  unittestConfiguration = new LaserTestConfiguration(laser);
}