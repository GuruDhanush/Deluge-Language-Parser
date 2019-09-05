import 'dart:collection';

import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/lsp/language/symbols.dart';
import 'package:DelugeDartParser/server/util.dart';

class SymbolServer {
  static _treeTraverseSymbols(List statements, List newLineTokens, [Uri uri]) {
    List<SymbolInformation> symbols = [];
    Queue statementQueue = Queue.from(statements);

    while (statementQueue.isNotEmpty) {
      var statement = statementQueue.removeFirst();

      if (statement is ForStatement) {
        statementQueue.add(statement.index);
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
      } else if (statement is ExpressionStatement) {
        var expr = statement.expression;
        if (expr is List && expr.isNotEmpty) {
          var assignmentExp = expr.first;
          if (assignmentExp is AssignmentExpression) {
            var identifier = assignmentExp.left;
            if (identifier is Identifier) statementQueue.add(identifier);
          }
        }
      } else if (statement is Identifier) {
        if (statement is Identifier) {
          var startLoc =
              Util.findLine(statement.start, statement.end, newLineTokens);

          symbols.add(SymbolInformation(
              kind: SymbolKind.Variable,
              name: statement.name,
              location: Location(
                  uri: uri,
                  range: Range(
                      start: Util.toPosition(startLoc),
                      end: Position(
                          line: startLoc.line,
                          character: startLoc.column + statement.length)))));
        }
      }
    }

    return symbols;
  }

  static findSymbols(List statements, List newLineTokens, [Uri uri]) {
    var symbols = _treeTraverseSymbols(statements, newLineTokens, uri);
    return symbols;
  }
}
