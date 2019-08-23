import 'dart:io';

import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/language/codelens.dart';
import 'package:DelugeDartParser/server/language/hover.dart';
import 'package:DelugeDartParser/server/language/signature.dart';
import 'package:DelugeDartParser/server/language/symbols.dart';
import 'package:DelugeDartParser/server/messaging/diagnostics.dart';
import 'package:DelugeDartParser/server/messaging/message.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
import 'package:DelugeDartParser/server/stdiochannel.dart';
import 'package:yaml/yaml.dart';

json_rpc.Peer peer;


main(List<String> arguments) {
  var ms = StdIOStreamChannel();
  peer = json_rpc.Peer(ms);
  var shutdown = false;
  // stderr.write('hi');

  //registers messages with peer to call from anywhere;;
  Message.registerMessage(peer);
  Diagnostics.registerDiagnostics(peer);
  Sync.register(peer);
  HoverProvider.registerHoverProvider(peer);
  SymbolProvider.register(peer);
  CodeLensProvider.register(peer);
  //SignatureProvider.register(peer);


  peer
    ..registerMethod('initialize', (params) async {
      return {
        'capabilities': 
          {
            'hoverProvider': true, 
            //Full sync on every change
            'textDocumentSync': 1,
            'documentSymbolProvider': true,
            'codeLensProvider': {
              'resolveProvider': true
            },
            'signatureHelpProvider': {
              'triggerCharacters': [ '(']
            }
          }
      };
    })
    ..registerMethod('shutdown', () {
      shutdown = true;
    })
    ..registerMethod('exit', () {
      return shutdown ? 0 : 1;
    });
  
  peer.listen();
}

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
// var parser = (digit().plus() & char(';'));
// var p = modTrace(parser);
// var result = p.parse('12a3;');

// Parser modTrace(Parser parser) {
//   var level = 0;
//  return transformParser(parser, (each) {
//    //print(each);
//     return ContinuationParser(each, (continuation, context) {
//       print('${'  ' * level}$each');
//       level++;
//       final result = continuation(context);
//       level--;
//       print('${'  ' * level}$result');
//       return result;
//     });
//   });
// }

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
