part of laser.server;

class FileWatcher {

  LaserConfiguration _conf;
  final _watchers = new Map<Stream<FileSystemEvent>, StreamSubscription<FileSystemEvent>>();

  final _controller = new StreamController<String>.broadcast();
  Stream<String> get stream => _controller.stream;

  FileWatcher(this._conf);

  void start() {
    _conf.directories.forEach((d) {
      Stream<FileSystemEvent> stream = new Directory(d).watch();
      _watchers[stream] = stream.listen(_onEvent,
        onError: _controller.addError,
        onDone: () => remove(stream));
      });
  }

  void _onEvent(FileSystemEvent event) {
    _controller.add(event.path);
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