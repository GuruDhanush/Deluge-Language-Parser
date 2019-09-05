import 'package:DelugeDartParser/lsp/messaging/diagnostics.dart';
import 'package:DelugeDartParser/server/server.dart';
import 'package:just_debounce_it/just_debounce_it.dart';
import 'package:DelugeDartParser/server/validation/validation.dart';



class WebServer {
  List newLineTokens;
  List statements;


  void onOpen(String text) {
    _parseFile(text);
  }


  void _parseFile(String text) {
     try {
      statements = DelugeServer.parseFile(text);
      newLineTokens = DelugeServer.parseNewLines(text);
      print('parsed correctly');
    } on DelugeParserException {
      print('parse error !');
    }

  }

   onChange(String text) {
    _parseFile(text);
  }


  List<Map> computeDiagnostics() {
    List<Diagnostic> diagnostics = ValidationServer.validate(this.statements, this.newLineTokens);
    
    return diagnostics != null ? WebDiagnostics.toJsonFromList(diagnostics) : null;

  }
}


class WebDiagnostics {

   final int startLineNumber;
   final int startColumn;
   final int endLineNumber;
   final int endColumn;
   final String message;
   final int severity;


  WebDiagnostics({this.startLineNumber, this.startColumn, this.endLineNumber, this.endColumn, this.message, this.severity});

  WebDiagnostics.fromDiagnostic(Diagnostic diagnostic) 
    : this(startLineNumber: diagnostic.range.start.line, 
          startColumn: diagnostic.range.start.character,
          endLineNumber: diagnostic.range.end.line,
          endColumn: diagnostic.range.end.character,
          message: diagnostic.message,
          severity: MarkerSeverity.toMarkerSecurity(diagnostic.severity)
    );
  
  static List<Map> toJsonFromList(List diagnostics) {
    List<Map> jsonDiagnostics = [];
    diagnostics.forEach((diag) => jsonDiagnostics.add( WebDiagnostics.fromDiagnostic(diag).toJson()));
    return jsonDiagnostics;
  }

  Map toJson() => {
    'startLineNumber': this.startLineNumber+1,
    'startColumn': this.startColumn+1,
    'endLineNumber': this.endLineNumber+1,
    'endColumn': this.endColumn+1,
    'message': this.message,
    'severity': this.severity
  };


}


class MarkerSeverity {
  static final int error = 8;
  static final int hint = 1;
  static final int info = 2;
  static final int warning = 4;

  static int toMarkerSecurity(DiagnosticSeverity diagnosticSeverity) {
    switch (diagnosticSeverity.index + 1) {
      case 1:
        return error;
      case 2:
        return warning;
      case 3:
        return info;
      case 4:
        return hint;
      default:
        return error;
    }

  }
}