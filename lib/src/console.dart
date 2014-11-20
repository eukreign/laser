part of laser.server;

class LaserConsole {

  LaserConfiguration _conf;

  LaserConsole(this._conf);

  TestTreeModel tree;

  void start() {


    
    /*
    print("Progress Bar");
    var bar = new ProgressBar(complete: 5);
    bar.update(5);
    print("${Icon.CHECKMARK} Icons");
    
    printTree({"label": "tests", "nodes": [{"label": "test 1", "nodes": [{"label": "sub test 1", "nodes": []}, {"label": "sub test 1", "nodes": []}]}]});
    */
    var i=0;
    new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
      Console.moveCursor(row: stdout.terminalLines, column: stdout.terminalColumns-2);
      Console.write((++i).toString());
    });
  }

  void draw_header() {
    Console.moveCursor(row: 0, column: 0);
    
  }

  void draw_test_tree(Map event) {
    Console.moveCursor(row: 2, column: 0);
    stdout.write(renderTree(tree.root));
  }

  void run_test(Map event) {

    Console.init();
    Console.eraseDisplay(2);
    Console.moveCursor(row: 1, column: 1);

    var port = new ReceivePort();
    var stream = port.asBroadcastStream();
    tree = new TestTreeModel(stream);
    tree.stream.listen(draw_test_tree);
    var test_file = path.join(Directory.current.path, event['test']);
    Isolate.spawnUri(test_file, [], port.sendPort).then((Isolate i) {
      
    });
  }
  
}

String renderTree(List<Map> nodes, {int level: 0, StringBuffer buffer, bool convertToString: true}) {
  buffer = buffer!=null ? buffer : new StringBuffer();

  nodes.forEach((node) {
    buffer.writeln(' '*level + node['group']);
    (node['tests'] as List).forEach((test) {
      buffer.writeln(' '*(level+1) + test['test']);
    });
  });

  if (convertToString) {
    return buffer.toString();
  }
  
  return '';

}