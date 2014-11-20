library laser.unittest.tree;

import 'dart:async';

class TestTreeModel {
  List<Map> root = [];
  Stream<Map> _isolate;
  final _controller = new StreamController<Map>.broadcast();
  Stream<Map> get stream => _controller.stream;

  TestTreeModel(this._isolate) {
    _isolate.listen((event) {
      switch (event['type']) {
        case 'start':
          break;
        case 'test_start':
          add_test(event['group'], event);
          break;
        case 'test_result':
        case 'test_result_changed':
          add_result(event);
          break;
        case 'done':
          break;
        case 'summary':
          record_summary(event);
          break;
        default:
          throw "Unsupported Event";
      }
      _controller.add(event);
    });
  }

  void add_test(Iterable<String> groupcrumbs, Map event, {List<Map> groups: null}) {

    groups = groups!=null ? groups: root;

    var currentGroup = groups.
        firstWhere(
          (node)=> node['group']==groupcrumbs.first,
          orElse: () {
            var newGroup = {'group': groupcrumbs.first, 'groups': [], 'tests': []};
            groups.add(newGroup);
            return newGroup;
          }
    );

    var remainingGroups = groupcrumbs.skip(1);
    if (remainingGroups.length == 0) {
      currentGroup['tests'].add(event);
    } else {
      add_test(remainingGroups, event, groups: currentGroup['groups']);
    }

  }

  void add_result(Map event) {
    var group = root;
    event['group'].forEach((g) {
      group = group.firstWhere((node) => node["group"]==g);
    });
    Map test = group['tests'].firstWhere((test) => test["test"]==event["test"]);
    test.addAll(event);
  }

  void record_summary(Map event) {
    
  }

}