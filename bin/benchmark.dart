import 'dart:io';

import 'package:DelugeDartParser/lexer.dart';
import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/parser.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:path/path.dart' as path;
import 'package:petitparser/petitparser.dart';


class ParserBenchmark extends BenchmarkBase {
  ParserBenchmark() : super('parser');

  static void main() {
    ParserBenchmark().report();
  }

  String input;
  var parser;

  void run() {
    Token.newlineParser().token().matchesSkipping(input);
    parser.parse(input);
  }

  void setup()  {
    input = File(path.join(Util.homeDir(), 'deluge-vscode', 'benchmark1.dg') ).readAsStringSync();
    parser = DelugeParser();
  }

  void teardown() {

  }

}