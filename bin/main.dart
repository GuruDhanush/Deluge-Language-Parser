import 'dart:io';

import 'package:DelugeDartParser/lexer.dart';
import 'package:DelugeDartParser/parser.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:graphs/graphs.dart' as gp;
import 'package:DelugeDartParser/node.dart';
import 'package:petitparser/reflection.dart';
import '../test/example/sample1.dart' as sample;

main(List<String> arguments) {

  // var parser = DelugeParser();
  // var input = sample.SAMPLE1;
  // int runs = 1000;
  // double time = 0;
  // for(var i = 0; i < runs; i++) {
  //   var watch = Stopwatch() ..start();
  //   var result = parser.parse(input);
  //   watch.stop();
  //   if(result.position != input.length) { print('error'); return;}
  //   time += watch.elapsedMicroseconds;
  // }
  // var totalTime = Duration(microseconds: time.toInt());
  // print('elapsed total time ${totalTime.inSeconds}s, average time: ${totalTime.inMilliseconds/runs}ms');
  // stdin.readLineSync();

  //var dg = DelugeParserDefinition();
  //var parser = modTrace(dg.build(start: dg.bigintLiteral));
  var parser = (digit().plus() | failure('Integer expected'));
  parser = modTrace( parser);
  var result = parser.parse('a123 ');
  
  

}

Parser modTrace(Parser parser) {
  var level = 0;
 return transformParser(parser, (each) {
    return ContinuationParser(each, (continuation, context) {
      print('${'  ' * level}$each');
      level++;
      final result = continuation(context);
      level--;
      print('${'  ' * level}$result');
      return result;
    });
  });
}

// class Graph {
//   final Map<Node, List<Node>> nodes;

//   Graph(this.nodes);
// }

// class Node {
//   final String id;
//   final int data;

//   Node(this.id, this.data);

//   @override
//   bool operator ==(Object other) => other is Node && other.id == id;

//   @override
//   int get hashCode => id.hashCode;

//   @override
//   String toString() => '<$id -> $data>';
// }
