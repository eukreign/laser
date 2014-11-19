library laser.console;

import 'dart:io';
import 'dart:async';
import 'package:console/console.dart';
import 'package:laser/configuration.dart';
import 'package:laser/server.dart';

class LaserConsole {

  LaserConfiguration _conf;
  LaserServer _server;

  LaserConsole(this._conf, this._server);

  void start() {
    Console.init();
    Console.eraseDisplay(2);
    Console.moveCursor(row: 0, column: 0);
    print("Progress Bar");
    var bar = new ProgressBar(complete: 5);
    bar.update(5);
    print("${Icon.CHECKMARK} Icons");

    printTree({"label": "tests", "nodes": [{"label": "test 1", "nodes": [{"label": "sub test 1", "nodes": []}, {"label": "sub test 1", "nodes": []}]}]});
    var i=0;
    new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
      Console.moveCursor(row: stdout.terminalLines, column: stdout.terminalColumns-2);
      Console.write((++i).toString());
    });
    
    
  }
  
  
}