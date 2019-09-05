import 'dart:io';

import 'package:DelugeDartParser/lsp/messaging/message.dart';
import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/server/language/symbols.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:petitparser/petitparser.dart';

class SymbolProvider {
  static register(Peer peer) {
    peer.registerMethod('textDocument/documentSymbol', onResolve);
  }

  static onResolve(Parameters param) {
    Uri uri = param['textDocument']['uri'].asUri;

    //TODO: Throw an error request
    if (!Sync.openFiles.containsKey(uri)) {
      Message.sendLogMessage(MessageType.error, 'File not found!!');
      return [];
    }
    var statements = Sync.openFiles[uri];

    //TODO: Throw an error request
    if (!Sync.newLineTokens.containsKey(uri)) {
      Message.sendLogMessage(MessageType.error, 'Newline tokens not found!!');
      return [];
    }
    var newLineTokens = Sync.newLineTokens[uri];

    return SymbolInformation.toJsonFromList(
        SymbolServer.findSymbols(statements, newLineTokens, uri));
  }
}

enum SymbolKind {
  Dummy, //dont use as the symbol kind starts  from file = 1 and dart enum is from 0
  File,
  Module,
  Namespace,
  Package,
  Class,
  Method,
  Property,
  Field,
  Constructor,
  Enum,
  Interface,
  Function,
  Variable,
  Constant,
  String,
  Number,
  Boolean,
  Array,
  Object,
  Key,
  Null,
  EnumMember,
  Struct,
  Event,
  Operator,
  TypeParameter,
}

class SymbolInformation {
  SymbolInformation({this.name, this.kind, this.location});

  String name;
  SymbolKind kind;
  Location location;

  Map toJson() =>
      {"name": name, "kind": kind.index, "location": location.toJson()};

  static List toJsonFromList(List<SymbolInformation> symbols) {
    var jsSymbols = [];
    //TODO: can also use symbols.join, take a look
    symbols.forEach((symbol) => jsSymbols.add(symbol.toJson()));
    return jsSymbols;
  }
}

class Location {
  Location({this.range, this.uri});

  Range range;
  Uri uri;

  Map toJson() => {"range": range.toJson(), "uri": uri.toString()};
}
