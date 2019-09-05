import 'dart:collection';

import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/lsp/messaging/diagnostics.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:petitparser/petitparser.dart';

class ValidationServer {
  static List<Diagnostic> validate(List statements,
      [List<Token> newLineTokens]) {
    List<Diagnostic> diagnostics = [];
    Queue statementQueue = Queue.from(statements);

    while (statementQueue.isNotEmpty) {
      var statement = statementQueue.removeFirst();

      if (statement is ForStatement) {
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
      } else if (statement is LineError) {
        var startLoc =
            Util.findLine(statement.start, statement.end, newLineTokens);

        var diagnostic = Diagnostic(
            code: 'Illegal line',
            message: 'Illegal line',
            source: 'Deluge lang server',
            severity: DiagnosticSeverity.error,
            range: Range(
                start: Util.toPosition(startLoc),
                end: Position(line: startLoc.line, character: statement.end)));

        diagnostics.add(diagnostic);
      }
    }
    return diagnostics;
  }
}
