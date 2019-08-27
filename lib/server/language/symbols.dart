import 'dart:io';

import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:petitparser/petitparser.dart';

class SymbolProvider {
  static register(Peer peer) {
    peer.registerMethod('textDocument/documentSymbol', onResolve);
  }

  static List<SymbolInformation> symbols = [];

  static treeTraverseSymbols(Object exp, Uri uri) {
    if (exp is List) {
      for (var line in exp) {
        treeTraverseSymbols(line, uri);
      }
    } else if (exp is BlockStatement) {
      for (var line in exp.body) {
        treeTraverseSymbols(line, uri);
      }
    } else if (exp is ForStatement) {
      treeTraverseSymbols(exp.index, uri);
      treeTraverseSymbols(exp.body, uri);
    } else if (exp is IfStatement) {
      treeTraverseSymbols(exp.consequent, uri);
      treeTraverseSymbols(exp.alternate, uri);
    } else if (exp is ExpressionStatement) {
      treeTraverseSymbols((exp.expression as List)[0], uri);
    } else if (exp is AssignmentExpression) {
      treeTraverseSymbols(exp.left, uri);
    } else if (exp is Identifier) {
      var line = findLine(exp.start, exp.end, Sync.newLineTokens[uri]);
      if (line != null) {
        symbols.add(SymbolInformation(
            kind: SymbolKind.Variable,
            name: exp.name,
            location: Location(
                uri: uri,
                range: Range(
                    start: Util.toPosition(line),
                    end: Position(line: line.line, character: line.column + exp.length)))));
      }
    }
  }
  
  //TODO: use binary search
  static Loc findLine(int startPos, int endPos, List<Token> tokens) {
    if(tokens == null) return null;
    for (int i = 0; i < tokens.length; i++) {
      var token = tokens[i];
      if (token.stop > startPos) {
         return Loc(line: i, column: startPos - (i == 0 ? 0 : tokens[i-1].stop));
      }
    }

    return null;
  }

  static onResolve(Parameters param) {
    Uri uri = param['textDocument']['uri'].asUri;

    if (!Sync.openFiles.containsKey(uri)) {
      return null;
    }

    var parseResult = Sync.openFiles[uri];
    symbols = [];
    treeTraverseSymbols(parseResult, uri);

    return SymbolInformation.toJsonFromList(symbols);
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
