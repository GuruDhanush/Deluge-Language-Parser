import 'dart:io';

import 'package:DelugeDartParser/lsp/language/codelens.dart';
import 'package:DelugeDartParser/lsp/language/hover.dart';
import 'package:DelugeDartParser/lsp/language/symbols.dart';
import 'package:DelugeDartParser/lsp/docs/docs.dart';
import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/lsp/messaging/diagnostics.dart';
import 'package:DelugeDartParser/lsp/messaging/message.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
import 'package:DelugeDartParser/lsp/stdiochannel.dart';
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
  Docs.register(peer);
  

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

