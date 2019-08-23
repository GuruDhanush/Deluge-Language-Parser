import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:json_rpc_2/json_rpc_2.dart';

class SymbolProvider {
  static register(Peer peer) {
    peer.registerMethod('textDocument/documentSymbol', onResolve);
  }

  static onResolve(Parameters param) {
    Uri uri = param['textDocument']['uri'].asUri;
    List<SymbolInformation> symbols = [];

    if (!Sync.openFiles.containsKey(uri)) {
      return null;
    }

    var parseResult = Sync.openFiles[uri];

    parseResult.forEach((line) {
      if (line is ForStatement) {
      } else if (line is IfStatement) {
      } else if (line is ExpressionStatement) {
        var exp = (line.expression as List)[0];
        if (exp is AssignmentExpression) {
          if (exp.left is Identifier) {
            var iden = exp.left as Identifier;
            symbols.add(SymbolInformation(
                kind: SymbolKind.Variable,
                name: iden.name,
                location: Location(
                    uri: uri,
                    range: Range(
                        start: Position(
                            line: line.startLoc.line,
                            character: line.startLoc.column),
                        end: Position(
                            line: line.startLoc.line,
                            character: line.startLoc.column + line.length)
                        )
                    )
                  )
                );
          }
        }
      }
    });

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
