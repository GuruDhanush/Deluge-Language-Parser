import 'dart:io';

import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/lsp/docs/docs.dart';
import 'package:DelugeDartParser/server/language/hover.dart';
import 'package:DelugeDartParser/lsp/messaging/message.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:petitparser/petitparser.dart' as prefix0;
import 'package:tuple/tuple.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

class HoverProvider {

  static registerHoverProvider(Peer peer) {
    peer.registerMethod('textDocument/hover', onHover);
  }


  static onHover(params) async {
    var docParams = TextDocumentPositionParams.fromJson(params);
    var uri = docParams.textDocument.uri;

    var loc = Loc(
        line: docParams.position.line, column: docParams.position.character);

    //TODO: Throw an error request
    if (!Sync.openFiles.containsKey(uri)) return [];
    var statements = Sync.openFiles[uri];

    //TODO: Throw an error request
    if (!Sync.newLineTokens.containsKey(uri)) return [];
    var newLineTokens = Sync.newLineTokens[uri];

    
    try {
      var pos = HoverServer.findPosition(loc, newLineTokens);
      var result = HoverServer.onHover(pos, statements);
      if(result != null) return result.toJson();

    } on PositionNotFoundException {
      Message.sendLogMessage(MessageType.info, 'Position not found');
    }
    return null;
  }

}

enum MarkupKind { plaintext, markdown }

class MarkupContent {
  MarkupKind kind;
  String value;

  Map toJson() => {
        'kind': MarkupKind.markdown == kind ? 'markdown' : 'plaintext',
        'value': value
      };

  MarkupContent({this.kind, this.value});
}

class Hover {
  MarkupContent content;
  Range range;
  Hover({this.content, this.range});

  Map toJson() => {
        'contents': content.toJson(),
        //'range': range.toJson()
      };
}

class TextDocumentPositionParams {
  TextDocumentIdentifier textDocument;
  Position position;
  TextDocumentPositionParams({this.textDocument, this.position});

  TextDocumentPositionParams.fromJson(params) {
    textDocument = TextDocumentIdentifier.fromJson(params['textDocument']);
    position = Position.fromJson(params['position']);
  }

  Map toJson() =>
      {'textDocument': textDocument.toJson(), 'position': position.toJson()};
}
