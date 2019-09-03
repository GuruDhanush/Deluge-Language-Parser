import 'dart:io';

import 'package:DelugeDartParser/lexer.dart';
import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/parser.dart';
import 'package:DelugeDartParser/server/docs/docs.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/language/codelens.dart';
import 'package:DelugeDartParser/server/language/hover.dart';
import 'package:DelugeDartParser/server/language/signature.dart';
import 'package:DelugeDartParser/server/language/symbols.dart';
import 'package:DelugeDartParser/server/messaging/diagnostics.dart';
import 'package:DelugeDartParser/server/messaging/message.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
import 'package:DelugeDartParser/server/stdiochannel.dart';
import 'package:petitparser/petitparser.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

json_rpc.Peer peer;


main(List<String> arguments) {
  var ms = StdIOStreamChannel();
  peer = json_rpc.Peer(ms);
  var shutdown = false;

  //registers messages with peer to call from anywhere;;
  Message.registerMessage(peer);
  Diagnostics.registerDiagnostics(peer);
  Sync.register(peer);
  HoverProvider.registerHoverProvider(peer);
  SymbolProvider.register(peer);
  CodeLensProvider.register(peer);
  //SignatureProvider.register(peer);
  Docs.fetchDocs();
  

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
            }
          }
      };
    })

    ..registerMethod("\$/cancelRequest", (param){
      //at the moment, when on any error, restart the server!!
      exit(1);
    })

    ..registerMethod('shutdown', (param) {
      shutdown = true;
      return null;
    })
    ..registerMethod('exit', (param) {
      peer.close();
      exit( shutdown ? 0 : 1);
    });
  
  peer.listen();
}

