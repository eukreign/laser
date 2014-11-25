import 'package:args/args.dart';
import 'package:laser/server.dart';

/*
 * TODO:
 * 
 *  - 'mapping' command that lists:
 *      1. files mapped to existant test files
 *      2. files mapped to non-existant test files
 *      3. .dart files found in watched directories but not mapped
 *      4. test files without associated input/src/trigger file
 * 
 *  - 'mapping dir/file' shows mapping for specific files
 * 
 *  - support comma delimited directores
 * 
 *  - support for default mapping, this would allow people to just list directories:
 * 
 *   mapping:
 *    - lib
 *    - lib/src
 *    - web
 * 
 *   And get the default: - "(\\w*?).dart": $1_test.dart  mapping.
 */

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