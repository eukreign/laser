library laser.test.conf;

import 'package:laser/console_unittest.dart';
import 'package:laser/src/utils.dart';

void main(args, port) { laser(port);

  group('test result builder', () {
    var builder = new TestBuilder();
    test('empty', () {
      expect(builder.root, equals([]));
    });
    test('test added to new group', () {
      builder.add(['group1','group2'], 'test1');
      expect(builder.root, equals([{'group': 'group1', 'groups': [{'group': 'group2', 'groups': [], 'tests': [{'label': 'test1'}]}], 'tests': []}]));
    });
    test('test added to same group', () {
      builder.add(['group1','group2'], 'test2');
      expect(builder.root, equals([{'group': 'group1', 'groups': [{'group': 'group2', 'groups': [], 'tests': [{'label': 'test1'}, {'label': 'test2'}]}], 'tests': []}]));
    });
  });

}