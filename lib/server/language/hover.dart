import 'dart:io';

import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/messaging/message.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

class HoverProvider {
  static Peer _peer;

  static registerHoverProvider(Peer peer) {
    _peer = peer;
    _peer.registerMethod('textDocument/hover', onHover);
  }

  static findLine(List lines, Loc loc) {
    Node resultLine;
    lines.forEach((line) {
      var temp = line as Node;
      if (!temp.startLoc.isBefore(loc)) {
        return;
      }
      resultLine = temp;
    });

    if (resultLine is ForStatement) {
      var forLine = resultLine as ForStatement;
      var block = forLine.body as BlockStatement;
      resultLine = findLine(block.body, loc);
    } else if (resultLine is IfStatement) {
      var ifLine = resultLine as IfStatement;
      var block = ifLine.consequent as BlockStatement;
      resultLine = findLine(block.body, loc);
      if (resultLine == null) {
        var conseq = ifLine.consequent;
        while (conseq is IfStatement) {
          var ifexp = conseq as IfStatement;
          var block = ifexp.consequent as BlockStatement;
          resultLine = findLine(block.body, loc);
          if (resultLine == null) {
            conseq = ifexp.alternate;
          }
        }

        if (conseq is BlockStatement) {
          resultLine = findLine(conseq.body, loc);
        }
      }
    }
    return resultLine;
  }

  static onHover(params) async {
    var docParams = TextDocumentPositionParams.fromJson(params);

    

    var result = Sync.openFiles[docParams.textDocument.uri];
    var loc = Loc(
        line: docParams.position.line + 1,
        column: docParams.position.character + 2);

    
    var finalResult = treeTraverse(loc, result);


//    Message.sendMessageNotif(MessageType.info, finalResult != null ? finalResult.runtimeType.toString() : 'null');

    var markUpContent = (String name) {

      var codeBlock = (code) => '```dg\n${code}\n```\n';
      var signature = (code) => '${codeBlock(code)}- - -\n';

      return MarkupContent(
        kind: MarkupKind.markdown,
        value: 
        '${signature(name)} }This is an doc line\n Shows info'
      );

    };

    return finalResult != null ? 
        Hover(
          content: markUpContent((finalResult as Identifier).name)
          //content: MarkupContent(kind: MarkupKind.markdown, value: (finalResult as Identifier).name)
        ).toJson() : null;


    // var hover = Hover(
    //   content:
    //       MarkupContent(kind: MarkupKind.markdown, value: '**Hello World**')
    // );
    
    
    // var resultLine = findLine(result, loc);

    // //return Hover(content: MarkupContent(kind: MarkupKind.plaintext, value: '${loc.line}:${loc.column}'));
    // if (resultLine is ExpressionStatement) {
    //   var mainBody = (resultLine.expression as List)[0];
    //   if (mainBody is AssignmentExpression) {
    //     return mainBody.onHover(loc);
    //   }
    // }
    // if (resultLine is CommentLine) {
    //   return null;
    // }

    //Binary search
    // int first = 0;
    // int last = result.length - 1;
    // while (first <= last) {
    //   int middle = (first + (last - 1) / 2).toInt();

    //   var line = result[middle] as Node;
    //   var nextLine = result[middle+1] as Node;
    //   var locationCurrent = line.startLoc.isBefore(loc);
    //   var locationNext = nextLine.startLoc.isAfter(loc);

    //   if (locationCurrent && locationNext) {
    //     resultLine = line;
    //   } else if (!locationCurrent && locationNext) {
    //     last = middle -1;
    //   } else {
    //     first = middle + 1;
    //   }
    // }

    //Message.sendMessageNotif(MessageType.info, resultLine.toString());

    //return hover.toJson();
  }

  static treeTraverse(Loc loc, Object exp) {

    if(exp is List) {
      for(var line in exp) {
        var result = treeTraverse(loc, line);
        if(result != null) return result;
      }
    } else if (exp is BlockStatement) {
      for (var line in exp.body) {
        var result = treeTraverse(loc, line);
        if (result != null) return result;
      }
    } else if (exp is ForStatement) {
      if (exp.index.isInside(loc) == 0) {
        return exp.index;
      }
      if (exp.list is Identifier &&
          (exp.list as Identifier).isInside(loc) == 0) {
        return  exp.list;
      }
      return treeTraverse(loc, exp.body);
    } else if (exp is IfStatement) {
      return treeTraverse(loc, exp.test) ??
          treeTraverse(loc, exp.consequent) ??
          treeTraverse(loc, exp.alternate);
    } else if(exp is Identifier && exp.isInside(loc) == 0) {
        return exp; 
    }
    else if(exp is LineError) {

    }
    else if (exp is CommentLine && exp.isInside(loc) == 0) {
      return null;
    } else if (exp is ExpressionStatement) {
      return treeTraverse(loc, (exp.expression as List)[0]);
    } else if (exp is AssignmentExpression) {
      return treeTraverse(loc, exp.left) ?? treeTraverse(loc, exp.right);
    } else if (exp is CallExpression) {
      for (var arg in exp.arguments) {
        var result = treeTraverse(loc, arg);
        if (result != null) return result;
      }
      return treeTraverse(loc, exp.callee);
    } else if (exp is MemberExpression) {
      return treeTraverse(loc, exp.object) ?? treeTraverse(loc, exp.propery);
    } else if (exp is BinaryExpression) {
      return treeTraverse(loc, exp.left) ?? treeTraverse(loc, exp.right);
    } else if (exp is LogicalExpression) {
      return treeTraverse(loc, exp.left) ?? treeTraverse(loc, exp.right);
    } else if (exp is ReturnStatement) {
      return treeTraverse(loc, exp.argument);
    } else if (exp is MapExpression) {
      for (var prop in exp.properties) {
        var result = treeTraverse(loc, prop);
        if (result != null) return result;
      }
    } else if (exp is ObjectProperty) {
      return treeTraverse(loc, exp.key) ?? treeTraverse(loc, exp.value);
    } else if (exp is InfoExpression) {
      return treeTraverse(loc, exp.argument);
    } else if (exp is IfExpression) {
      return treeTraverse(loc, exp.test) ??
          treeTraverse(loc, exp.value) ??
          treeTraverse(loc, exp.alternate);
    } else if(exp is IfNullExpression) {
      return treeTraverse(loc, exp.value) ??
          treeTraverse(loc, exp.alternate);
    } else if(exp is UnaryExpression) {
      return treeTraverse(loc, exp.expression);
    } else if(exp is ObjectExpression) {
      for(var prop in exp.properties) {
        var result = treeTraverse(loc, prop) ;
        if(result != null) return result;
      }
    } else if(exp is ListExpression) {
      for(var prop in exp.elements) {
        var result = treeTraverse(loc, prop);
        if(result != null) return result;
      }
    } else if(exp is InvokeFunction) {
      for(var prop in exp.args) {
        var result = treeTraverse(loc, prop);
        if(result != null) return result;
      }
    } else if (exp is BooleanLiteral ||
        exp is BigIntLiteral ||
        exp is DecimalLiteral ||
        exp is StringLiteral) {
      return null;
    } 
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
