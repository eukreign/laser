library laser.unittest;

import 'dart:isolate';
import 'package:unittest/src/utils.dart' as unittest_utils;
import 'package:unittest/unittest.dart';
export 'package:unittest/unittest.dart';

void laser(port) {
  if (port != null) {
    groupSep = '~';
    unittestConfiguration = new LaserTestConfiguration(port);
  }
}

class _ExpectFailureHandler extends DefaultFailureHandler {
  final LaserTestConfiguration _config;

  _ExpectFailureHandler(this._config);

  void fail(String reason) {
    _config.onExpectFailure(reason);
  }
}

class LaserTestConfiguration extends Configuration {

  SendPort _port;

  // The VM won't shut down if a receive port is open. Use this to make sure
  // we correctly wait for asynchronous tests.
  ReceivePort _receivePort;

  /// Subclasses can override this with something useful for diagnostics.
  /// Particularly useful in cases where we have parent/child configurations
  /// such as layout tests.
  String get name => 'Configuration';

  bool get autoStart => true;

  /// If true (the default), throw an exception at the end if any tests failed.
  bool throwOnTestFailures = true;

  /// If true (the default), then tests will stop after the first failed
  /// [expect]. If false, failed [expect]s will not cause the test
  /// to stop (other exceptions will still terminate the test).
  bool stopTestOnExpectFailure = true;

  // If stopTestOnExpectFailure is false, we need to capture failures, which
  // we do with this List.
  final _testLogBuffer = <unittest_utils.Pair<String, StackTrace>>[];

  /// The constructor sets up a failure handler for [expect] that redirects
  /// [expect] failures to [onExpectFailure].
  LaserTestConfiguration(this._port): super.blank() {
    configureExpectFailureHandler(new _ExpectFailureHandler(this));
  }

  void onInit() {
    // For Dart internal tests, we don't want stack frame filtering.
    // We turn it off here in the default config, but by default turn
    // it back on in the vm and html configs.
    filterStacks = false;
    _receivePort = new ReceivePort();
    _postMessage('unittest-suite-wait-for-done');
  }

  /// Called when each test starts. Useful to show intermediate progress on
  /// a test suite. Derived classes should call this first before their own
  /// override code.
  void onTestStart(TestCase testCase) {
    assert(testCase != null);
    _testLogBuffer.clear();
    _port.send({
      'type': 'test_started',
      'test': testCase.description.substring(testCase.currentGroup.length+1),
      'group': testCase.currentGroup});
  }

  /// Called when each test is first completed. Useful to show intermediate
  /// progress on a test suite. Derived classes should call this first
  /// before their own override code.
  void onTestResult(TestCase testCase) {
    assert(testCase != null);
    if (!stopTestOnExpectFailure && _testLogBuffer.length > 0) {
      // Write the message/stack pairs up to the last pairs.
      var reason = new StringBuffer();
      for (var reasonAndTrace in
             _testLogBuffer.take(_testLogBuffer.length - 1)) {
        reason.write(reasonAndTrace.first);
        reason.write('\n');
        reason.write(reasonAndTrace.last);
        reason.write('\n');
      }
      var lastReasonAndTrace = _testLogBuffer.last;
      // Write the last message.
      reason.write(lastReasonAndTrace.first);
      if (testCase.result == PASS) {/*
        testCase._result = FAIL;
        testCase._message = reason.toString();
        // Use the last stack as the overall failure stack.
        testCase._stackTrace = lastReasonAndTrace.last;*/
      } else {
        // Add the last stack to the message; we have a further stack
        // caused by some other failure.
        reason.write(lastReasonAndTrace.last);
        reason.write('\n');
        // Add the existing reason to the end of the expect log to
        // create the final message.
        //testCase._message = '${reason.toString()}\n${testCase._message}';
      }
    }
  }

  void onTestResultChanged(TestCase testCase) {
    assert(testCase != null);
  }

  /// Handles the logging of messages by a test case. The default in
  /// this base configuration is to call print();
  void onLogMessage(TestCase testCase, String message) {
    _postMessage(message);
  }

  /// Handles failures from expect(). The default in
  /// this base configuration is to throw an exception;
  void onExpectFailure(String reason) {
    if (stopTestOnExpectFailure) {
      throw new TestFailure(reason);
    } else {
      try {
        throw '';
      } catch (_, stack) {
        var trace = unittest_utils.getTrace(stack, formatStacks, filterStacks);
        if (trace == null) trace = stack;
        _testLogBuffer.add(new unittest_utils.Pair<String, StackTrace>(reason, trace));
      }
    }
  }

  /// Format a test result.
  String formatResult(TestCase testCase) {
    var result = new StringBuffer();
    result.write(testCase.result.toUpperCase());
    result.write(": ");
    result.write(testCase.description);
    result.write("\n");

    if (testCase.message != '') {
      result.write(unittest_utils.indent(testCase.message));
      result.write("\n");
    }

    if (testCase.stackTrace != null) {
      result.write(unittest_utils.indent(testCase.stackTrace.toString()));
      result.write("\n");
    }
    return result.toString();
  }

  /// Called with the result of all test cases.
  ///
  /// The default implementation prints the result summary using the built-in
  /// [print] command. Browser tests commonly override this to reformat the
  /// output.
  ///
  /// When [uncaughtError] is not null, it contains an error that occured
  /// outside of tests (e.g. setting up the test).
  void onSummary(int passed, int failed, int errors, List<TestCase> results,
      String uncaughtError) {
    // Print each test's result.
    for (final t in results) {
      //_port.send(formatResult(t).trim());
    }

    // Show the summary.
    _postMessage('');

    if (passed == 0 && failed == 0 && errors == 0 && uncaughtError == null) {
      _postMessage('No tests found.');
      // This is considered a failure too.
    } else if (failed == 0 && errors == 0 && uncaughtError == null) {
      _postMessage('All $passed tests passed.');
    } else {
      if (uncaughtError != null) {
        _postMessage('Top-level uncaught error: $uncaughtError');
      }
      _postMessage('$passed PASSED, $failed FAILED, $errors ERRORS');
    }
  }

  void onDone(bool success) {
    if (success) {
      _postMessage('unittest-suite-success');
      _receivePort.close();
    } else {
      _receivePort.close();
      if (throwOnTestFailures) {
        throw new Exception('Some tests failed.');
      }
    }
  }

  void _postMessage(String message) {
    // In dart2js browser tests, the JavaScript-based test controller
    // intercepts calls to print and listens for "secret" messages.
    //_port.send(message);
  }
}