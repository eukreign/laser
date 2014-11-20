library laser.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:console/console.dart';

import 'src/utils.dart';

part 'src/configuration.dart';
part 'src/console.dart';
part 'src/websockets_server.dart';
part 'src/filewatcher_server.dart';


class LaserServer {
  
  LaserConfiguration _conf;
  WebSockets _webSockets;
  FileWatcher _fileWatcher;
  LaserConsole _console;
  Stream<Map> get stream => _fileWatcher.stream;

  LaserServer(this._conf);

  Future start({bool start_console: false}) {
    _webSockets = new WebSockets(_conf);
    _fileWatcher = new FileWatcher(_conf);
    _console = new LaserConsole(_conf);

    if (start_console)
      _console.start();
    _fileWatcher.start();
    _fileWatcher.stream.listen(send_event);
    return _webSockets.start();
  }

  void send_event(Map event) {
    if ((event["test"] as String).endsWith("html")) {
      _webSockets.broadcast(event);
    } else {
      _console.run_test(event);
    }
  }

  Future stop() {
    _fileWatcher.stop();
    return _webSockets.stop();
  }
}