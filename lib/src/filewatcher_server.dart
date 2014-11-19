library laser.server.filewatcher;

import 'dart:io';
import 'dart:async';
import 'package:laser/configuration.dart';

class FileWatcher {

  LaserConfiguration _conf;
  final _watchers = new Map<Stream<FileSystemEvent>, StreamSubscription<FileSystemEvent>>();

  Stream<Map> get stream => _controller.stream;
  final _controller = new StreamController<Map>.broadcast();

  FileWatcher(this._conf) {
    
  }

  void start() {
    _conf.directories.forEach((d) {
      Stream<FileSystemEvent> stream = new Directory(d).watch();
      _watchers[stream] = stream.listen(_onEvent,
        onError: _controller.addError,
        onDone: () => remove(stream));
      });
  }

  void _onEvent(FileSystemEvent event) {
    var test = _conf.test_for(event.path);
    _controller.add({'changed': event.path, 'test': test});
  }

  void remove(Stream<FileSystemEvent> stream) {
    var watcher = _watchers.remove(stream);
    if (watcher != null) watcher.cancel();
  }

  void stop() {
    for (var watcher in _watchers.values) {
      watcher.cancel();
    }
    _watchers.clear();
    _controller.close();
  }

}