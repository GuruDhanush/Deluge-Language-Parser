

import 'dart:convert';
import 'dart:io';
import 'package:DelugeDartParser/server/util.dart';
import 'package:path/path.dart' as p;

class Docs {

  static Map _docs = Map();

  static fetchDocs() async {
    var docFile = File(p.join(Util.homeDir(), 'deluge-vscode', 'docs.json'));
    _docs = (json.decode(await docFile.readAsString()) as Map)['functions'];
  }

  static searchDoc(String name) {
    if(_docs.containsKey(name)) {
      return _docs[name];
    }
  }



}