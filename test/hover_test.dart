import 'dart:convert';
import 'dart:io';

import 'package:DelugeDartParser/lsp/language/hover.dart';
import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/parser/parser.dart';
import 'package:DelugeDartParser/lsp/docs/docs.dart';
import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/server/language/codelens.dart';
import 'package:DelugeDartParser/server/language/hover.dart';
import 'package:DelugeDartParser/server/server.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:DelugeDartParser/server/validation/validation.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:DelugeDartParser/server/language/symbols.dart';

import 'example/sample1.dart';

void main() {


  group('a = 1 identifier', () {
    var statements;
    var newLineTokens;
    final uri = Uri.parse('file://1');
    var parameters;

    setUp((){
      var input = """
      a = 1;
      """;
      statements = DelugeParser().parse(input).value;
      newLineTokens = Token.newlineParser().token().matchesSkipping(input);
      Sync.openFiles[uri] = statements;
      Sync.newLineTokens[uri] = newLineTokens;
      parameters = json_rpc.Parameters("textDocument/hover", {
        "textDocument": {
          "uri": uri.toString()
        },
        "position": {
          "line": 0,
          "character": 6
        }
      });
    });

    test('server', () {
      var result = HoverServer.onHover(6, statements);
      expect(result, isNull);
    });


    test('lsp', () async {
      expect(await HoverProvider.onHover(parameters), isNull);
    });

    test('lsp with no newLineTokens', () async {
      Sync.newLineTokens.remove(uri);
      var result = await HoverProvider.onHover(parameters);
      expect(result, isEmpty);
    });

    test('lsp with no statements', () async {
      Sync.openFiles.remove(uri);
      var result = await HoverProvider.onHover(parameters);
      expect(result, isEmpty);
    });

  });



  test('load doc', () async {
    var docFile = File(path.join("c:\\Users\\Guru\\AppData\\Roaming\\Code - Insiders\\User\\globalStorage\\gdp.delugelang\\v0.05-alpha", "docs.json"));
    var docs = (json.decode(await docFile.readAsString()) as Map)['functions'];
    expect(docs, isNotEmpty);
  }, skip: 'only on installed extensions');

  test('search doc', () async {
    await Docs.fetchDocs(path.join("c:\\Users\\Guru\\AppData\\Roaming\\Code - Insiders\\User\\globalStorage\\gdp.delugelang\\v0.05-alpha", "docs.json"));
    var putDoc = Docs.searchDoc('trim');
    expect(putDoc, isNotEmpty);
  }, skip: 'only on installed extensions');

}
