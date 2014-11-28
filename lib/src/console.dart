part of laser.server;


class LaserConsole implements LaserUI {

  TestSession _session = new TestSession(null);

  LaserConsole();

  void message(String msg) {
    Terminal.eraseDisplay(2);
    Terminal.moveCursor(row: 2, column: 2);
    Terminal.write(msg);
  }

  void set session(TestSession session) {
    _session = session;
    _session.stream.listen(draw_test_tree);
  }

  void start() {
    draw_header();
    draw_footer();
    var i = 0;
    new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
      Terminal.moveCursor(row: Terminal.rows, column: Terminal.columns-5);
      Terminal.write((++i).toString());
    });
    stdin.echoMode = false;
    stdin.lineMode = false;
    stdin.listen((List<int> key) {
      Terminal.moveCursor(row: 1, column: 1);
      Terminal.write(key);
      switch (key) {
        case '^[[A':
          Terminal.write('up');
          break;
        case '^[[B':
          Terminal.write('down');
          break;
      }
    });
  }
  
  void draw_header() {
    Terminal.moveCursor(row: 1, column: 1);
    Terminal.write("${_session.testFile}");
  }

  void draw_test_tree(Map event) {
    Terminal.eraseDisplay(2);
    draw_header();
    Terminal.moveCursor(row: 2, column: 0);
    Terminal.write(renderTree(_session.model));
    draw_footer();
  }

  void draw_footer() {
    Terminal.moveCursor(row: Terminal.rows, column: 1);
    Terminal.write("${_session.tests.padLeft(5)} tests:");
    Terminal.write("${_session.passed.padLeft(5)} passed");
    Terminal.write("${_session.failed.padLeft(5)} failed");
    Terminal.write("${_session.errors.padLeft(5)} errors");
    Terminal.write("${_session.skipped.padLeft(5)} skipped");
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