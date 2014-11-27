library laser.test.console;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:laser/unittest_io.dart';
import 'package:laser/server.dart';
import 'package:console/console.dart';


class TestStdout implements Stdout {
  StringBuffer buffer;
  String get str => buffer.toString();
  bool hasTerminal = true;
  int terminalColumns = 80;
  int terminalLines = 20;
  TestStdout() {
    buffer = new StringBuffer();
  }
  Encoding get encoding => stdout.encoding;
  void set encoding(Encoding encoding) {}
  void write(object) => buffer.write(object);
  void writeln([object = "" ]) => buffer.writeln(object);
  void writeAll(objects, [sep = ""]) => buffer.writeAll(objects, sep);
  void add(List<int> data) => buffer.write(data.join());
  void addError(error, [StackTrace stackTrace]) => buffer.write(error);
  void writeCharCode(int charCode) => buffer.writeCharCode(charCode);
  Future addStream(Stream<List<int>> stream) => stream.listen((data) => buffer.write(data)).asFuture();
  Future flush() => new Future.value();
  Future close() => new Future.value();
  Future get done => new Future.value();
}


void main([args, port]) { laser(port);
  group('header rendering', () {
    test('initial header', () {
      var stdout = new TestStdout();
      var term = new Terminal(stdout);
      term.centerCursor();
      expect(stdout.str, equals(Terminal.ANSI_ESCAPE+"10;40H"));
    });
  });
}