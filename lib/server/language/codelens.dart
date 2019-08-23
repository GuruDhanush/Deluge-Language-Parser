import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:json_rpc_2/json_rpc_2.dart';

class CodeLensProvider {
  static register(Peer peer) {
    peer.registerMethod('textDocument/codeLens', provideCodeLens);
    peer.registerMethod('codeLens/resolve', resolveCodeLens);
  }

  static provideCodeLens(Parameters param) {
    Uri uri = param['textDocument']['uri'].asUri;
    List<CodeLens> codeLens = [];

    var parseResult = Sync.openFiles[uri];

    parseResult.forEach((line) {
      if (line is ForStatement) {
      } else if (line is IfStatement) {
      } else if (line is ExpressionStatement) {
        var exp = (line.expression as List)[0];
        if (exp is AssignmentExpression) {
          if (exp.right is InvokeFunction) {
            var invFunc = exp.right as InvokeFunction;
            
            invFunc.args.forEach((arg) {
              var prop = arg as ObjectProperty;
              if(prop.key is Identifier && (prop.key as Identifier).name.toLowerCase() == 'message') {
                var iden = prop.key as Identifier;
                var content = '';
                if(prop.value is StringLiteral) {
                  var stringData = (prop.value as StringLiteral).raw;
                  content = stringData.substring(1).substring(0, stringData.length-2);
                }

                codeLens.add(CodeLens(
                command: Command(title: 'Show View', command: 'delugelang.showView', arg: content),
                range: Range(
                    start: Position(
                        line: iden.startLoc.line,
                        character: iden.startLoc.column),
                    end: Position(
                        line: iden.startLoc.line,
                        character: iden.startLoc.column + iden.length)
                      )
                )
                );
              }

            });

            
          }
        }
      }
    });

    return CodeLens.toJsonFromList(codeLens); 
  }
  
  //TODO: potentially stale data
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

  Map toJson() => {'title': title, 'command': command, 'arguments': [arg]};
}

class CodeLens {
  CodeLens({this.range, this.data, this.command});

  Range range;
  Command command;

  //can be any type used string for easy serialisation
  String data;


  Map toJson() => {'range': range.toJson(), 'data': data, 'command': command.toJson()};

  static List toJsonFromList(List<CodeLens> codeLens) {
    var jsCodeLens = [];
    //TODO: can also use symbols.join, take a look
    codeLens.forEach((symbol) => jsCodeLens.add(symbol.toJson()));
    return jsCodeLens;
  }
}
