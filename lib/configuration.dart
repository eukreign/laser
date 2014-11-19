library laser.conf;

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

abstract class Template {
  
  var _context;

  noSuchMethod(Invocation invocation) {
    if (!invocation.isGetter) return super.noSuchMethod(invocation);
    return _context[invocation.memberName];
  }

  String template();

  String evaluate(context) {
    _context = context;
    try {
      return template();
    } finally { _context = null; }
  }
}

class LaserConfiguration {
  Map conf;

  String test_directory = "test";
  
  LaserConfiguration(String yaml) {
    conf = loadYaml(yaml);
  }

  LaserConfiguration.fromPath(String path) {
    conf = loadYaml(new File(path).readAsStringSync());
  }  

  List<String> get directories => conf.keys.toList();

  String test_for(String file) {
    List<Map> matchers = conf[path.dirname(file)];
    var fname = path.basename(file);
    for (var matcher in matchers) {
      var firstKey = matcher.keys.first;

      // try exact match
      if (firstKey == fname) {
        return path.join(test_directory, matcher[firstKey]);
      }

      // try regex match
      var regex = new RegExp(firstKey);
      if (regex.hasMatch(fname)) {
        var m = regex.firstMatch(fname);
        var test = matcher[firstKey];
        for (var i = 0; i <= m.groupCount; ++i) {
          test = test.replaceAll(new RegExp(r"\$"+"${i}"), m.group(i));
        }
        return path.join(test_directory, test);
      }
    }
    return null;
  }
}