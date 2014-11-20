part of laser.server;

class LaserConsole {

  LaserConfiguration _conf;

  LaserConsole(this._conf);

  Map tree = {"label": "tests", "nodes": []};

  void start() {

    Console.init();
    Console.eraseDisplay(2);
    Console.moveCursor(row: 0, column: 0);
    
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

  void draw_test_tree() {
    Console.moveCursor(row: 1, column: 0);
    printTree(tree);
  }

  void update_test_result(Map event) {
    switch (event['type']) {
      case 'test_started':
        tree["label"] = event["group"];
        (tree["nodes"] as List).add(event["test"]);
        draw_test_tree();
    }   
  }

  void run_test(Map event) {
    var res = new ReceivePort();
    res.listen(update_test_result);
    var test_file = path.join(Directory.current.path, event['test']);
    Isolate.spawnUri(test_file, [], res.sendPort).then((Isolate i) {
      
    });
  }
  
}