import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/lsp/language/codelens.dart';
import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/parser/parser.dart';
import 'package:DelugeDartParser/server/language/codelens.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';



void main() {

  test('binary exp to string', () {

    var expression = BinaryExpression(
        left: StringLiteral(value: [ '"', "Hello".split(''), '"' ] ,raw: '"Hello"'),
        oopertor: '+',
        right: Identifier('id')
    );

    expect(CodeLensServer.convertBinaryToString(expression), equalsIgnoringCase('Hello {Variable} '));
    
  });

  group('sendsms codelens', () {

    var statements;
    var newLineTokens;
    final uri = Uri.parse('file://1');
    var parameters;

    setUp((){
      var input = """
      a = sendsms [
        message: "Hello" + hi
      ];
      """;
      statements = DelugeParser().parse(input).value;
      newLineTokens = Token.newlineParser().token().matchesSkipping(input);
      Sync.openFiles[uri] = statements;
      Sync.newLineTokens[uri] = newLineTokens;
      parameters = json_rpc.Parameters("textDocument/hover", {
        "textDocument": {
          "uri": uri.toString()
        }
      });
    });
    
    test('server', () {

      var codeLens = CodeLensServer.treeTraversalCodeLens(statements, newLineTokens);

      expect(codeLens.length, 1);
      var item = codeLens.first;
      var start = item.range.start;
      var end = item.range.end;

      expect(item.command.arg, "Hello {Variable} ");
      expect(start.line, 1);
      expect(start.character, 8);
      
      expect(end.line, 1);
      expect(end.character, 15);
    });

    test('lsp', () {

      var result = CodeLensProvider.provideCodeLens(parameters);

      expect(result, equals([
        {
          "range": {
            "start": {
              "line": 1,
              "character": 8
            },
            "end": {
              "line": 1,
              "character": 15
            }
          },
          "data": null,
          "command": {
            "title": "Show View",
            "command": "delugelang.showView",
            "arguments": [
              "Hello {Variable} "
            ]
          }
        }
      ]));

      
    });


  });

}