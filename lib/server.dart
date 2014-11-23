library laser.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:console/console.dart';

part 'src/configuration.dart';
part 'src/console.dart';
part 'src/chrome.dart';
part 'src/filewatcher_server.dart';
part 'src/test_runner.dart';
part 'src/test_session.dart';
part 'src/websockets.dart';


class LaserTestServer {

  final test_sessions = new Map<String, TestSession>();

  LaserConfiguration conf;

  LaserConsole console;
  LaserChrome chrome;

  IsolateTestRunner isolate_runner;
  HeadlessTestRunner headless_runner;
  IncomingWebTests incoming;

  FileWatcher fileWatcher;

  LaserTestServer(this.conf);

  Future start({bool start_console: false}) {

    // UIs
    chrome = new LaserChrome(); // also a test runner
    console = new LaserConsole(this);

    if (start_console)
      console.start();

    // Test Runners
    isolate_runner = new IsolateTestRunner();
    headless_runner = new HeadlessTestRunner(); // along with chrome, uses websockets

    // WebSocket Test Connections
    incoming = new IncomingWebTests();
    incoming.stream.listen((runner) {
      test_connected(runner);
    });

    // File Watcher
    fileWatcher = new FileWatcher(conf);
    fileWatcher.start();
    fileWatcher.stream.listen((String path) {
      var test = conf.test_for(path);
      start_test(test);
    });

    return Future.wait([chrome.start(), incoming.start()]);

  }

  void start_test(String test) {

    var runner;

    if (test.endsWith("html")) {
      runner = chrome;
    } else {
      runner = isolate_runner;
    }

    runner.run(test).then((runner) {
      test_connected(runner);
    });

  }

  void test_connected(TestRunnerInstance runner) {

    StreamSubscription subscription = runner.stream.listen(null);
    subscription.onData((Map details) {
      var test = details['test'];
      var session = test_sessions.putIfAbsent(test, ()=>new TestSession(test));
      console.session = session;
      subscription.onData((Map data) => session.onData(data));
      session.init(runner);
    });

  }

  Future stop() {
    fileWatcher.stop();
    return webSockets.stop();
  }
}