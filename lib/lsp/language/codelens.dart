import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/server/language/codelens.dart';
import 'package:json_rpc_2/json_rpc_2.dart';

class CodeLensProvider {
  static register(Peer peer) {
    peer.registerMethod('textDocument/codeLens', provideCodeLens);
    peer.registerMethod('codeLens/resolve', resolveCodeLens);
  }

  static provideCodeLens(Parameters param) {
    Uri uri = param['textDocument']['uri'].asUri;

    //TODO: Throw an error request
    if (!Sync.openFiles.containsKey(uri)) return [];
    var statements = Sync.openFiles[uri];

    //TODO: Throw an error request
    if (!Sync.newLineTokens.containsKey(uri)) return [];
    var newLineTokens = Sync.newLineTokens[uri];

    return CodeLens.toJsonFromList(
        CodeLensServer.treeTraversalCodeLens(statements, newLineTokens));
  }

  //TODO: potentially stale data Will resolve after incremental compilation
  static resolveCodeLens(Parameters param) {
    return param;
  }
}

class Command {
  Command({this.title, this.command, this.arg});

  String title;
  String command;
  //List arguments; using single arg
  String arg;

  Map toJson() => {
        'title': title,
        'command': command,
        'arguments': [arg]
      };
}

class CodeLens {
  CodeLens({this.range, this.data, this.command});

  Range range;
  Command command;

  //can be any type used string for easy serialisation
  String data;

  Map toJson() =>
      {'range': range.toJson(), 'data': data, 'command': command.toJson()};

  static List toJsonFromList(List<CodeLens> codeLens) {
    var jsCodeLens = [];
    //TODO: can also use symbols.join, take a look
    codeLens.forEach((symbol) => jsCodeLens.add(symbol.toJson()));
    return jsCodeLens;
  }
}
