import 'dart:convert';

import 'package:json_rpc_2/json_rpc_2.dart';

import '../document/sync.dart';

class Diagnostics {

  static Peer _peer;

  static void registerDiagnostics(Peer peer) {
    _peer = peer;
  }

  static publishDiagnostics(Uri uri, List<Diagnostic> diagnostics) {
    var params = PublishDiagnosticsParams(uri: uri, diagnostics: diagnostics);
    _peer.sendNotification('textDocument/publishDiagnostics', params.toJson());
  }

  static publishParserStatus(bool status) {
    _peer.sendNotification('custom/updateStatusBarItem',  { "status": status });
  }

}

class PublishDiagnosticsParams {

  Uri uri;
  List<Diagnostic> diagnostics;

  PublishDiagnosticsParams({this.uri, this.diagnostics});

  Map toJson() => {
    'uri': uri.toString(),
    'diagnostics': Diagnostic.toJsonFromList(this.diagnostics)
  };
  

}

class Diagnostic {

  ///The range at which the diagnostic applies
  Range range;

  /// The diagnostic's severity, if ommitted it's up to client
  DiagnosticSeverity severity;

  /// The diagnostic's code to be shown in UI
  String code;

  /// The source of this diagnostic like 'deluge lang server'
  String source = 'Deluge Language Server';

  /// The diagnostic's message
  String message;

  Diagnostic({this.range, this.severity, this.code, this.source, this.message});


  static List<Map> toJsonFromList(List<Diagnostic> diagnostics) {
    List<Map> jsonDiagnostics = [];
    diagnostics.forEach((diag) => jsonDiagnostics.add(diag.toJson()));
    return jsonDiagnostics;
  }

  Map toJson() => {
    'range': range.toJson(),
    //as the dart enum starts from 0, while protocol starts from 1
    'severity': severity.index + 1,
    'code': code,
    'source': source,
    'message': message
  };

}

/// The diagnostics severity
enum DiagnosticSeverity {
  error,
  warning,
  information,
  hint
}