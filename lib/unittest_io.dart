library laser.unittest;

import 'dart:isolate';

import 'package:unittest/unittest.dart';
export 'package:unittest/unittest.dart';

part 'src/unittest_configuration.dart';

void laser(port) {
  if (port != null) {
    groupSep = GROUP_SEP;
    unittestConfiguration = new LaserTestConfiguration(port);
  }
}