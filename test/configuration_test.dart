library laser.test.conf;

import 'package:unittest/unittest.dart';
import 'package:laser/configuration.dart';

void main() {
  test('directories list', () {
    var c = new LaserConfiguration('lib:\nweb:\nlib/src:');
    expect(c.directories, unorderedEquals(["lib", "web", "lib/src"]));
  });
  test('mapping basic', () {
    var c = new LaserConfiguration('lib/src:\n  - app.dart: app_test.html');
    expect(c.test_for('lib/src/app.dart'), equals('test/app_test.html'));
  });
  test('mapping w/ regex', () {
    var c = new LaserConfiguration('lib/src:\n'+r'  - "(\\w*?).dart": $1_test.html');
    expect(c.test_for('lib/src/myapp.dart'), equals('test/myapp_test.html'));
  });
}