library laser.unittest;

import 'dart:async';
import 'dart:isolate';

import 'package:unittest/unittest.dart';
export 'package:unittest/unittest.dart';

part 'src/unittest_configuration.dart';

class IsolateConnection implements LaserConnection {

  ReceivePort _receivePort;
  SendPort _sendPort;

  IsolateConnection(this._sendPort) {
    _receivePort = new ReceivePort();
    _sendPort.send(_receivePort.sendPort);
  }

  Future get ready {
    return new Future.value();
  }

  void send(message) {
    _sendPort.send(message);
  }

  StreamSubscription listen(onData(Map data)) {
    return _receivePort.listen(onData);
  }

}

void laser(port) {
  if (port != null) {
    groupSep = GROUP_SEP;
    LaserConnection laser = new IsolateConnection(port);
    unittestConfiguration = new LaserTestConfiguration(laser);
  }
}