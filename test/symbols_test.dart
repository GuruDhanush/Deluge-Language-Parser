import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/lsp/language/symbols.dart';
import 'package:DelugeDartParser/parser/parser.dart';
import 'package:DelugeDartParser/server/language/symbols.dart';
import 'package:DelugeDartParser/web/server.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;


void main() {

  group('lsp', () {
    final fileUri = Uri.parse('file://1');
    setUp(() {
      var input = """ 
      a = 1;
      """;
      Sync.openFiles[fileUri] = DelugeParser().parse(input).value;
      Sync.newLineTokens[fileUri] =
          Token.newlineParser().token().matchesSkipping(input);
    });

    test('with single symbol', () {
      var parameters = json_rpc.Parameters("textDocument/documentSymbol", {
        "textDocument": {"uri": fileUri.toString()}
      });

      var symbols = SymbolProvider.onResolve(parameters);

      var symbol = symbols[0] as Map;
      var location = symbol["location"];
      var start = location["range"]["start"];
      var end = location["range"]["end"];

      expect(symbols, isNotEmpty);
      expect('a', symbol["name"]);
      expect(13, symbol["kind"]);

      
      expect(fileUri.toString(), location["uri"]);

      //start pos
      expect(0, start["line"]);
      expect(6, start["character"]);

      //end pos
      expect(0, end["line"]);
      expect(7, end["character"]);
    });


    test('on empty newline tokens', () {
      Sync.openFiles.remove(fileUri);
      var parameters = json_rpc.Parameters("textDocument/documentSymbol", {
        "textDocument": {"uri": fileUri.toString()}
      });

      try {
        SymbolProvider.onResolve(parameters);
      } catch (e) {
        return;
      }
      assert(false);      
    });

    test('on empty statements', () {
      Sync.newLineTokens.remove(fileUri);
      var parameters = json_rpc.Parameters("textDocument/documentSymbol", {
        "textDocument": {"uri": fileUri.toString()}
      });

      try {
        SymbolProvider.onResolve(parameters);
      } catch (e) {
        return;
      }
      assert(false);     
      
    });
  
  });

  group('three symbols', () {
    var newLineTokens;
    var statements;

    setUp(() {
      var input = """ 
      a = 1;
      b = 2;
      c = 3;
      """;
      statements = DelugeParser().parse(input).value;
      newLineTokens = Token.newlineParser().token().matchesSkipping(input);
    });

    test('full one symbol', () {
      var symbols = SymbolServer.findSymbols(statements, newLineTokens);
      var range = symbols[0].location.range;

      expect(symbols, isNotEmpty);
      expect('a', symbols[0].name);
      expect(SymbolKind.Variable, symbols[0].kind);
      expect(0, range.start.line);
      expect(6, range.start.character);
      expect(0, range.end.line);
      expect(7, range.end.character);
    });

    test('server', () {
      var symbols = SymbolServer.findSymbols(statements, newLineTokens);

      expect(symbols, isNotEmpty);
      expect(symbols.length, 3);
      expect(symbols[0].name, 'a');
      expect(symbols[1].name, 'b');
      expect(symbols[2].name, 'c');
    });

    test('web', () {
      var symbols = SymbolServer.findSymbols(statements, newLineTokens);
      var webSymbols = WebDocumentSymbol.toJsonFromList(symbols);

      expect(webSymbols, isNotEmpty);
      expect(webSymbols[0]['name'], 'a');
      expect(webSymbols[1]['name'], 'b');
      expect(webSymbols[2]['name'], 'c');
    });

  });

  group('nested if symbols', () {
    var newLineTokens;
    var statements;

    setUp(() {
      var input = """ 
      if(true) {
        a = 1;
      }
      """;
      statements = DelugeParser().parse(input).value;
      newLineTokens = Token.newlineParser().token().matchesSkipping(input);
    });

    test('server', () {
      var symbols = SymbolServer.findSymbols(statements, newLineTokens);

      expect(symbols, isNotEmpty);
      expect(symbols.length, 1);

      var symbol = symbols[0];
      var start = symbol.location.range.start;
      var end = symbol.location.range.end;

      expect(symbol.name, 'a');
      expect(symbol.kind, SymbolKind.Variable);

      expect(start.line, 1);
      expect(start.character, 8);

      expect(end.line, 1);
      expect(end.character, 9);
     
    });

    test('web', () {
      var symbols = SymbolServer.findSymbols(statements, newLineTokens);
      var webSymbols = WebDocumentSymbol.toJsonFromList(symbols);

      expect(webSymbols, isNotEmpty);
      var symbol = webSymbols[0];
      
      var range = symbol['range'];

      expect(symbol['name'], 'a');
      expect(symbol['kind'], SymbolKind.Variable.index);

      expect(range['startLineNumber'], 1);
      expect(range['startColumn'], 8);
      
      expect(range['endLineNumber'], 1);
      expect(range['endColumn'], 9);
    });

  });

  group('for symbols', () {
    var newLineTokens;
    var statements;

    setUp(() {
      var input = """ 
      for each i in lists 
      {
        a = 1;
      }
      """;
      statements = DelugeParser().parse(input).value;
      newLineTokens = Token.newlineParser().token().matchesSkipping(input);
    });

    test('server', () {
      var symbols = SymbolServer.findSymbols(statements, newLineTokens);

      expect(symbols, isNotEmpty);
      expect(symbols.length, 2);

      var symbol = symbols[0];
      var start = symbol.location.range.start;
      var end = symbol.location.range.end;

      expect(symbol.name, 'i');
      expect(symbol.kind, SymbolKind.Variable);

      expect(start.line, 0);
      expect(start.character, 15);

      expect(end.line, 0);
      expect(end.character, 16);


      symbol = symbols[1];
      start = symbol.location.range.start;
      end = symbol.location.range.end;

      expect(symbol.name, 'a');
      expect(symbol.kind, SymbolKind.Variable);

      expect(start.line, 2);
      expect(start.character, 8);

      expect(end.line, 2);
      expect(end.character, 9);
     
    });

    test('web', () {
      var symbols = SymbolServer.findSymbols(statements, newLineTokens);
      var webSymbols = WebDocumentSymbol.toJsonFromList(symbols);

      expect(webSymbols, isNotEmpty);
      var symbol = webSymbols[0];
      
      var range = symbol['range'];

      expect(symbol['name'], 'i');
      expect(symbol['kind'], SymbolKind.Variable.index);

      expect(range['startLineNumber'], 0);
      expect(range['startColumn'], 15);
      
      expect(range['endLineNumber'], 0);
      expect(range['endColumn'], 16);


      symbol = webSymbols[1];
      
      range = symbol['range'];

      expect(symbol['name'], 'a');
      expect(symbol['kind'], SymbolKind.Variable.index);

      expect(range['startLineNumber'], 2);
      expect(range['startColumn'], 8);
      
      expect(range['endLineNumber'], 2);
      expect(range['endColumn'], 9);
    });

  });
}
