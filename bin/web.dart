import 'dart:html';

import 'package:DelugeDartParser/web/server.dart';
import 'package:just_debounce_it/just_debounce_it.dart';

const Duration _debounceDuration = Duration(milliseconds: 300);

class DelugeWorker {
  DedicatedWorkerGlobalScope DWS = DedicatedWorkerGlobalScope.instance;

  DelugeWorker() {
    print('worker started!');

    var server = WebServer();
    DWS.onMessage.listen((MessageEvent event) {
      var method = event.data['method'];
      var params = event.data['params'];

      //print('method: $method, params: $params');

      if (method == 'onOpen') {
        server.onOpen(params as String);
        var diagnostics = server.computeDiagnostics();
        DWS.postMessage({'method': 'diagnostics', 'params': diagnostics});
      } else if (method == 'onChange') {

        Debounce.duration(_debounceDuration, () {
          server.onChange(params as String);
          var diagnostics = server.computeDiagnostics();
          DWS.postMessage({'method': 'diagnostics', 'params': diagnostics});
        });
      }
    });
  }
}

main() {
  DelugeWorker();
}
