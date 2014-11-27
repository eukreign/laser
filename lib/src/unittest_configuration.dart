part of laser.unittest;


String GROUP_SEP = '~';

abstract class LaserConnection {
  Future get ready;
  void send(data);
  StreamSubscription listen(onData(Map data));
}

class LaserTestConfiguration extends SimpleConfiguration {

  ReceivePort _receivePort;

  LaserConnection _laser;

  bool get autoStart => false;

  LaserTestConfiguration(this._laser): super() {
    _laser.ready.then((_) {
      _laser.send({'test': 'configuration_test.dart'});
      _laser.listen((Map data) {
        this.limit = data["limit"];
        runTests();
      });
    });
  }

  List<int> limit = [];

  void onInit() {
    _receivePort = new ReceivePort();
  }

  void onStart() {
    var tests = [];
    if (limit.isNotEmpty) {
      testCases.forEach((TestCase testCase) {
        if (!limit.contains(testCase.id)){
          disableTest(testCase.id);
        }
      });
    }
    _laser.send({'type': 'start', 'tests': testCases.map((tc) => _serializeTestCase(tc)).toList()});
  }

  void onTestStart(TestCase testCase) {
    super.onTestStart(testCase);
    _laser.send(_serializeTestCase(testCase)..["type"] = "test_start");
  }

  void onTestResult(TestCase testCase, {String event_name: "test_result"}) {
    super.onTestResult(testCase);
    var event = _serializeTestCase(testCase);
    event['type'] = event_name;
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

Map _serializeTestCase(TestCase testCase) {
  return {
    'id': testCase.id,
    'test': testCase.description.substring(testCase.currentGroup.length+1),
    'group': testCase.currentGroup.split(GROUP_SEP)
  };
}