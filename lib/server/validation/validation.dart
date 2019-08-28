import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/messaging/diagnostics.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:petitparser/petitparser.dart';

class Validation {
  static List<Diagnostic> Validate(List statements, Uri uri) {
    List<Diagnostic> diagnostics = [];

    for (var statement in statements) {
      if (statement is LineError) {
        var syncDocs = Sync.newLineTokens[uri];
        if(syncDocs == null) {
          return diagnostics;
        }

        var startLoc = uri != null
            ? findLine(statement.start, statement.end, syncDocs)
            : Loc(line: 0, column: 0);
        //if(startLoc.line == syncDocs.length -1) return diagnostics;
        if(startLoc == null) continue;

        var diagnostic = Diagnostic(
            code: 'Illegal line',
            message: 'Illegal line',
            source: 'Deluge lang server',
            severity: DiagnosticSeverity.error,
            range: Range(
                start: Util.toPosition(startLoc),
                end: Position(line: startLoc.line, character: statement.end)));

        diagnostics.add(diagnostic);
        //return diagnostics;
      } else if (statement is IfStatement) {
        if (statement.consequent is BlockStatement) {
          var block = statement.consequent as BlockStatement;
          List<Object> blockstatements = block.body;
          diagnostics.addAll(Validate(blockstatements.cast<Node>(), uri));
        }
        var alternate = statement.alternate;
        if (alternate != null) {
          while (alternate is! BlockStatement) {
            var ifstmt = alternate as IfStatement;
            var consequent = ifstmt.consequent as BlockStatement;
            List<Object> consequentstatements = consequent.body;
            diagnostics
                .addAll(Validate(consequentstatements.cast<Node>(), uri));

            alternate = ifstmt.alternate;
          }
          var finalBlock = alternate as BlockStatement;
          List<Object> finalBlockStatements = finalBlock.body;
          diagnostics.addAll(Validate(finalBlockStatements.cast<Node>(), uri));
        }
      } else if (statement is ForStatement) {
        if (statement.body is BlockStatement) {
          var block = statement.body as BlockStatement;
          List<Object> blockstatements = block.body;
          diagnostics.addAll(Validate(blockstatements.cast<Node>(), uri));
        }
      }
    }
    return diagnostics;
  }

  //TODO: use binary search
  static Loc findLine(int startPos, int endPos, List<Token> tokens) {
    for (int i = 0; i < tokens.length; i++) {
      var token = tokens[i];
      if (token.stop > startPos) {
        return Loc(
            line: i, column: startPos - (i == 0 ? 0 : tokens[i - 1].stop));
      }
    }
    //for last line
    return Loc(line: tokens.length, column: 0);
  }
}
