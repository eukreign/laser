library laser.server;

import 'dart:async';

import 'configuration.dart';
import 'src/websockets_server.dart';
import 'src/filewatcher_server.dart';

class LaserServer {
  
  LaserConfiguration _conf;
  WebSockets _webSockets;
  FileWatcher _fileWatcher;
  
  LaserServer(this._conf);

  Future start() {
    _webSockets = new WebSockets(_conf);
    _fileWatcher = new FileWatcher(_conf);
    _fileWatcher.start();
    _fileWatcher.stream.listen(send_event);
    return _webSockets.start();
  }

  void send_event(Map event) {
    _webSockets.broadcast(event);
  }

  Future stop() {
    _fileWatcher.stop();
    return _webSockets.stop();
  }
}