import 'package:args/args.dart';
import 'package:laser/server.dart';


main(List<String> arguments) {

  final parser = new ArgParser();
  ArgResults args = parser.parse(arguments);
  List<String> paths = args.rest;

  LaserConfiguration conf;
  if (paths.isNotEmpty) {
    conf = new LaserConfiguration.fromPath(paths.first);
  } else {
    conf = new LaserConfiguration.fromPath('laser.yaml');
  }

  var server = new LaserTestServer(conf);
  server.start(start_console: true);

}