library laser.test.conf;

import 'package:laser/unittest_io.dart';
import 'package:laser/server.dart';

void main([args, port]) { laser(port);

  group('yaml config processing', () {
    test('directories list', () {
      var c = new LaserConfiguration('mapping:\n  lib:\n  web:\n  lib/src:');
      expect(c.directories, unorderedEquals(["lib", "web", "lib/src"]));
    });
    test('mapping basic', () {
      var c = new LaserConfiguration('mapping:\n  lib/src:\n    - app.dart: app_test.html');
      expect(c.test_for('lib/src/app.dart'), equals('test/app_test.html'));
    });
    test('mapping w/ regex', () {
      var c = new LaserConfiguration('mapping:\n  lib/src:\n'+r'    - "(\\w*?).dart": $1_test.html');
      expect(c.test_for('lib/src/myapp.dart'), equals('test/myapp_test.html'));
    });
  });
}