part of laser.server;


class LaserConsole implements LaserUI {

  TestSession _session;
  Terminal _term;

  LaserConsole(this._term);

  void message(String msg) {
    _term.eraseDisplay(2);
    _term.moveCursor(row: 2, column: 2);
    _term.write(msg);
  }

  void set session(TestSession session) {
    _session = session;
    _session.stream.listen(draw_test_tree);
  }

  void start() {
    var i = 0;
    new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
      _term.moveCursor(row: _term.rows, column: _term.columns-5);
      _term.write((++i).toString());
    });
  }

  void draw_test_tree(Map event) {
    _term.eraseDisplay(2);
    _term.moveCursor(row: 2, column: 0);
    _term.write(renderTree(_session.model));
  }

}

String renderTree(List<Map> nodes, {int level: 0, StringBuffer buffer, bool convertToString: true}) {

  buffer = buffer!=null ? buffer : new StringBuffer();

  nodes.forEach((node) {
    buffer.writeln(' '*level + node['group']);
    (node['tests'] as List).forEach((Map test) {
      if (test.containsKey("result")) {
        if (test["result"] == "pass") {
          buffer.writeln("${' '*(level+1)} \u2714 ${test['test']}");
        } else {
          buffer.writeln("${' '*(level+1)} x ${test['test']}");
        }
      } else {
        buffer.writeln("${' '*(level+1)} \u2022 ${test['test']}");
      }
    });
  });

  if (convertToString) {
    return buffer.toString();
  }

  return '';

}