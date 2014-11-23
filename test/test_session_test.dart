library laser.test.test_tree;

import 'dart:async';
import 'package:laser/unittest_io.dart';
import 'package:laser/server.dart';

void main([args, port]) { laser(port);

  group('test result builder', () {
    var controller = new StreamController<Map>(sync: true);
    var tree = new TestRunModel();
    test('empty', () {
      expect(tree.root, equals([]));
    });
    test('test added to new group', () {
      tree.add_test(['group1','group2'], {"test": "test1", "id": 1});
      expect(tree.root, equals([{'group': 'group1', 'groups': [{'group': 'group2', 'groups': [], 'tests': [{'test': 'test1', 'id': 1}]}], 'tests': []}]));
    });
    test('test added to same group', () {
      tree.add_test(['group1','group2'], {"test": "test2", "id": 2});
      expect(tree.root, equals([{'group': 'group1', 'groups': [{'group': 'group2', 'groups': [], 'tests': [{'test': 'test1', 'id': 1}, {'test': 'test2', 'id': 2}]}], 'tests': []}]));
    });
  });

}