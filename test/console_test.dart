library laser.test.console;

import 'package:laser/unittest_io.dart';
import 'package:laser/server.dart';
import 'package:console/console.dart';


void main([args, port]) { laser(port);
  var output = useStringStdout();
  var console = new LaserConsole();

  setUp(() => output.clear());

  group('header rendering', () {
    test('initial header', () {
      console.draw_footer();
      expect(output.str, equals("Edit and save a watched file to trigger associated tests."));
      //expect(stdout.str, equals(Terminal.ANSI_ESCAPE+"10;40H"));
    });
  });
}