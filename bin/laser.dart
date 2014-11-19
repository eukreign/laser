import 'package:args/args.dart';
import 'package:laser/configuration.dart';
import 'package:laser/server.dart';
import 'package:laser/console.dart';

main(List<String> arguments) {
  final parser = new ArgParser();
  ArgResults args = parser.parse(arguments);
  List<String> paths = args.rest;

  var conf = new LaserConfiguration.fromPath(paths.first);
  var server = new LaserServer(conf);
  server.start().then((_) {
    new LaserConsole(conf, server).start();
  });

}