import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:petitparser/petitparser.dart';

class CodeLensProvider {
  static register(Peer peer) {
    peer.registerMethod('textDocument/codeLens', provideCodeLens);
    peer.registerMethod('codeLens/resolve', resolveCodeLens);
  }

  static List<CodeLens> codeLens = [];

  static treeTraversalCodeLens(Object exp, Uri uri) {
    if (exp is List) {
      for (var line in exp) {
        treeTraversalCodeLens(line, uri);
      }
    } else if (exp is BlockStatement) {
      for (var line in exp.body) {
        treeTraversalCodeLens(line, uri);
      }
    } else if (exp is ForStatement) {
      treeTraversalCodeLens(exp.index, uri);
      treeTraversalCodeLens(exp.body, uri);
    } else if (exp is IfStatement) {
      treeTraversalCodeLens(exp.consequent, uri);
      treeTraversalCodeLens(exp.alternate, uri);
    } else if (exp is ExpressionStatement) {
      treeTraversalCodeLens((exp.expression as List)[0], uri);
    } else if (exp is AssignmentExpression) {
      treeTraversalCodeLens(exp.right, uri);
    } else if (exp is InvokeFunction) {
      exp.args.forEach((arg) {
        var prop = arg as ObjectProperty;
        if (prop.key is Identifier &&
            (prop.key as Identifier).name.toLowerCase() == 'message') {
          var iden = prop.key as Identifier;
          var content = '';
          if (prop.value is StringLiteral) {
            var stringData = (prop.value as StringLiteral).raw;
            content =
                stringData.substring(1).substring(0, stringData.length - 2);
          }
          if(prop.value is BinaryExpression) {
            content = ConvertBinaryToString(prop.value);
          }

          var loc = findLine(iden.start, iden.end, Sync.newLineTokens[uri]);

          if(loc != null) {

            codeLens.add(CodeLens(
                command: Command(
                    title: 'Show View',
                    command: 'delugelang.showView',
                    arg: content),
                range: Range(
                    start: Util.toPosition(loc),
                    end: Position(
                        line: loc.line,
                        character: loc.column + iden.length))));
          }
        }
      });
    }
  }

  //TODO: use binary search
  static Loc findLine(int startPos, int endPos, List<Token> tokens) {
    for (int i = 0; i < tokens.length; i++) {
      var token = tokens[i];
      if (token.stop > startPos) {
         return Loc(line: i, column: startPos - (i == 0 ? 0 : tokens[i-1].stop));
      }
    }

    return null;
  }

  static String ConvertBinaryToString(BinaryExpression expression) {

    var right = expression.right;
    var left = expression.left;
    String data = '';
    if(right is StringLiteral) {
      data = (right.value[1] as List).join('');
    }
    else {
      data = ' {Variable} ' + data;
    }
    if(left is BinaryExpression) {
      data = ConvertBinaryToString(left) + data;
    }
    if(left is StringLiteral) {
      data = (left.value[1] as List).join('') + data;
    }
    return data;

  }

  static provideCodeLens(Parameters param) {
    Uri uri = param['textDocument']['uri'].asUri;
    var parseResult = Sync.openFiles[uri];

    codeLens = [];
    treeTraversalCodeLens(parseResult, uri);
  
    return CodeLens.toJsonFromList(codeLens);
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
