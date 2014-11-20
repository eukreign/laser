library laser.test.conf;

import 'dart:async';
import 'package:laser/console_unittest.dart';
import 'package:laser/src/test_tree.dart';

void main(args, port) { laser(port);

  group('test result builder', () {
    var controller = new StreamController<Map>(sync: true);
    var tree = new TestTreeModel(controller.stream);
    test('empty', () {
      expect(tree.root, equals([]));
    });
    test('test added to new group', () {
      controller.add({"type": "test_start", "group": ['group1','group2'], "test": 'test1'});
      expect(tree.root, equals([{'group': 'group1', 'groups': [{'group': 'group2', 'groups': [], 'tests': [{'label': 'test1'}]}], 'tests': []}]));
    });
    test('test added to same group', () {
      controller.add({"type": "test_start", "group": ['group1','group2'], "test": 'test2'});
      expect(tree.root, equals([{'group': 'group1', 'groups': [{'group': 'group2', 'groups': [], 'tests': [{'label': 'test1'}, {'label': 'test2'}]}], 'tests': []}]));
    });
  });

}