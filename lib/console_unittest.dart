library laser.unittest;

import 'dart:io';
import 'dart:async';
import 'dart:isolate';

import 'package:unittest/unittest.dart';
export 'package:unittest/unittest.dart';

import 'package:unittest/vm_config.dart';

String GROUP_SEP = '~';

void laser(port) {
  if (port != null) {
    groupSep = GROUP_SEP;
    unittestConfiguration = new LaserTestConfiguration(port);
  }
}

class LaserTestConfiguration extends VMConfiguration {

  ReceivePort _receivePort;
  SendPort _laser;

  bool get autoStart => true;

  LaserTestConfiguration(this._laser): super();
  
  void onInit() {
    _receivePort = new ReceivePort();
  }

  void onStart() {
    _laser.send({'type': 'start'});
  }

  void onTestStart(TestCase testCase) {
    super.onTestStart(testCase);
    _laser.send(_prepareEvent("test_start", testCase));
  }

  void onTestResult(TestCase testCase, {String event_name: "test_result"}) {
    super.onTestResult(testCase);
    var event = _prepareEvent(event_name, testCase);
    event['result'] = testCase.result;
    event['message'] = testCase.message;
    if (testCase.stackTrace != null) {
      event['stackTrace'] = testCase.stackTrace.toString();
    }
    _laser.send(event);
  }

  void onTestResultChanged(TestCase testCase) {
    onTestResult(testCase, event_name: "test_result_changed");
  }

  void onDone(bool success) {
    _laser.send({'type': 'done', 'success': success});
    _receivePort.close();
  }

  void onSummary(int passed, int failed, int errors, List<TestCase> results, String uncaughtError) {
    _laser.send({
      'type':'summary',
      'passed': passed,
      'failed': failed,
      'errors': errors,
      'uncaught_error': uncaughtError
    });
  }

}

Map _prepareEvent(String type, TestCase testCase) {
  return {
    'type': type,
    'id': testCase.id,
    'test': testCase.description.substring(testCase.currentGroup.length+1),
    'group': testCase.currentGroup.split(GROUP_SEP)
  };
}