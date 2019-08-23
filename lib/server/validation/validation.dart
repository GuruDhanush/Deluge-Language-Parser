import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/messaging/diagnostics.dart';

class Validation {
  static List<Diagnostic> Validate(List<Node> statements) {
    List<Diagnostic> diagnostics = [];

    for (var statement in statements) {
      if (statement is LineError) {
        var startPos = Position(
            line: statement.startLoc.line,
            character: statement.startLoc.column);

        var endPos = Position(
            line: statement.endLoc.line, character: statement.endLoc.column);

        var diagnostic = Diagnostic(
            code: 'Illegal line',
            message: 'Illegal line',
            source: 'Deluge lang server',
            severity: DiagnosticSeverity.error,
            range: Range(start: startPos, end: endPos));

        diagnostics.add(diagnostic);
      } else if (statement is IfStatement) {
        if (statement.consequent is BlockStatement) {
          var block = statement.consequent as BlockStatement;
          List<Object> blockstatements = block.body;
          diagnostics.addAll(Validate(blockstatements.cast<Node>()));
        }
        var alternate = statement.alternate;
        if (alternate != null) {
          while (alternate is! BlockStatement) {
            var ifstmt = alternate as IfStatement;
            var consequent = ifstmt.consequent as BlockStatement;
            List<Object> consequentstatements = consequent.body;
            diagnostics.addAll(Validate(consequentstatements.cast<Node>()));

            alternate = statement.alternate;
          }
          var finalBlock = alternate as BlockStatement;
          List<Object> finalBlockStatements = finalBlock.body;
          diagnostics.addAll(Validate(finalBlockStatements.cast<Node>()));
        }
      } else if (statement is ForStatement) {
        if (statement.body is BlockStatement) {
          var block = statement.body as BlockStatement;
          List<Object> blockstatements = block.body;
          diagnostics.addAll(Validate(blockstatements.cast<Node>()));
        }
      }
    }
    return diagnostics;
  }
}
