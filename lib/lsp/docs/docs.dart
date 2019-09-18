import 'dart:convert';
import 'dart:io';
import 'package:DelugeDartParser/server/util.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:path/path.dart' as path;

class Docs {
  
  ///registers the docs provider. After receiving an event from the client about the docs location
  ///it updates the doc object to be consumed by the server. 
  static register(Peer peer) {
    peer.registerMethod('custom/updateDocsLocation', (params) {
      String folderDir = params['folder'].asString;
      String fileName = params['fileName'].asString;

      fetchDocs(path.join(folderDir, fileName));
    });
  }

  static Map _docs = Map();

  ///fetches docs from the given file path and updates the docs object. 
  ///Gets called by [Docs.register(peer)] method to update.
  static fetchDocs(String filePath) async {
    if (filePath == null) return;
    try {
      var docFile = File(filePath);
      _docs = (json.decode(await docFile.readAsString()) as Map)['functions'];
    } catch (ex) {
      print('Couldn\'t load docs!! ${ex}');
    }
  }

  static searchDoc(String name) {
    if (_docs.containsKey(name)) {
      return _docs[name];
    }
  }
}
