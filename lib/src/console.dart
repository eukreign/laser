part of laser.server;


class LaserConsole {

  LaserTestServer _server;
  LaserConfiguration _conf;
  LaserConsole(this._server) {
    _conf = _server.conf;
  }

  TestSession _session;
  void set session(TestSession session) {
    Console.init();
    Console.eraseDisplay(2);
    //Console.moveCursor(row: 1, column: 1);
    _session = session;
    _session.stream.listen(draw_test_tree);
  }

  void start() {
    var i=0;
    new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
      Console.moveCursor(row: stdout.terminalLines, column: 30);
      Console.write((++i).toString());
       
    });
  }

  void draw_test_tree(Map event) {
    Console.moveCursor(row: 2, column: 0);
    stdout.write(renderTree(_session.model));
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