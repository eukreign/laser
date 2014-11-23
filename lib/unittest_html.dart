library laser.unittest;

import 'dart:html';
import 'dart:isolate';

import 'package:unittest/unittest.dart';
export 'package:unittest/unittest.dart';

part 'src/unittest_configuration.dart';

void laser() {
  var ws = new WebSocket('ws://localhost:2014');
  if (ws != null) {
    groupSep = GROUP_SEP;
    unittestConfiguration = new LaserTestConfiguration(ws);
  }
}