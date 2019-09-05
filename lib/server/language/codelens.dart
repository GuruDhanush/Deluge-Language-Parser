import 'dart:collection';

import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/lsp/language/codelens.dart';
import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/server/util.dart';

class CodeLensServer {
  static List<CodeLens> treeTraversalCodeLens(
      List statements, List newLineTokens) {
    List<CodeLens> codeLens = [];
    Queue statementQueue = Queue.from(statements);

    while (statementQueue.isNotEmpty) {
      var statement = statementQueue.removeFirst();

      if (statement is ExpressionStatement) {
        var expr = statement.expression;
        if (expr is List && expr.isNotEmpty) {
          var assignmentExp = expr.first;
          if (assignmentExp is AssignmentExpression) {
            var invokeFunc = assignmentExp.right;
            if (invokeFunc is InvokeFunction) {
              var invokeParams = invokeFunc.args;
              invokeParams.forEach((param) {
                var prop = param as ObjectProperty;
                if (prop.key is Identifier &&
                    (prop.key as Identifier).name.toLowerCase() == 'message') {
                  var iden = prop.key as Identifier;
                  String content = '';

                  if (prop.value is StringLiteral) {
                    var stringData = (prop.value as StringLiteral).raw;
                    content = stringData
                        .substring(1)
                        .substring(0, stringData.length - 2);
                  }

                  if (prop.value is BinaryExpression) {
                    content = convertBinaryToString(prop.value);
                  }

                  var loc = Util.findLine(iden.start, iden.end, newLineTokens);

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
              });
            }
          }
        }
      } else if (statement is ForStatement) {
        var block = statement.body;
        if (block is BlockStatement) {
          statementQueue.addAll(block.body);
        }
      } else if (statement is IfStatement) {
        if (statement.consequent is BlockStatement) {
          var block = statement.consequent as BlockStatement;
          statementQueue.addAll(block.body);
        }
        var alternate = statement.alternate;
        if (alternate != null) {
          while (alternate != null && alternate is IfStatement) {
            IfStatement ifstmt = alternate as IfStatement;
            if (ifstmt == null || ifstmt.consequent == null) break;
            var consequent = ifstmt.consequent as BlockStatement;
            statementQueue.addAll(consequent.body);
            alternate = ifstmt.alternate;
          }
          if (alternate != null) {
            statementQueue.addAll((alternate as BlockStatement).body);
          }
        }
      }
    }

    return codeLens;
  }

  static String convertBinaryToString(BinaryExpression expression) {
    var right = expression.right;
    var left = expression.left;
    String data = '';
    if (right is StringLiteral) {
      data = (right.value[1] as List).join('');
    } else {
      data = ' {Variable} ' + data;
    }
    if (left is BinaryExpression) {
      data = convertBinaryToString(left) + data;
    }
    if (left is StringLiteral) {
      data = (left.value[1] as List).join('') + data;
    }
    return data;
  }
}
