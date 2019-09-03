import 'package:DelugeDartParser/lexer.dart';
import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/parser.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/messaging/diagnostics.dart';
import 'package:DelugeDartParser/server/validation/validation.dart';
import 'package:petitparser/petitparser.dart' as prefix0;
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'example/sample1.dart';

void main() {
  Parser parser;
  setUp(() {
    parser = DelugeParser();
  });

  test('normal', () {
    var input = SAMPLE3;
    var result = parser.parse(input);
    List<Object> statements = result.value;
    var validations = Validation.Validate(statements.cast<Node>(), null);
    expect(validations.length, isNonZero);
  },skip: 'validation api change');

  test('check diagnostics', () {
    List<Diagnostic> diagnostics = [
      Diagnostic(
          code: 'code',
          message: 'message',
          range: Range(
            start: Position(line: 1, character: 1),
            end: Position(line: 1, character: 4),
          ),
          severity: DiagnosticSeverity.error,
          source: "Deluge Language Server")
    ];

    var params = PublishDiagnosticsParams(
        uri: Uri.parse('file:///c%3A/Users/Guru/Desktop/sample.dg'),
        diagnostics: diagnostics);

    print(params.toJson());
  });

  test('check diagnostics 2', () {
    var result = DGParser.parse(SAMPLE3);
    List<Object> statements = result.value;
    var validations = Validation.Validate(statements.cast<Node>(), null);
    var params = PublishDiagnosticsParams(
        uri: Uri.parse('file:///c%3A/Users/Guru/Desktop/sample.dg'),
        diagnostics: validations);
    print(params.toJson());
  });

  test('read diagnostics', () {
    var params = {
      "textDocument": {
        "uri": "file:///c%3A/Users/Guru/Desktop/sample.dg",
        "version": 3
      },
      "contentChanges": [
        {
          "text":
              "response  Map();\r\n \r\nres = Collection();\r\nresponse.put(\"bot\",{\"name\":\"OneDrive\"});\r\nif(arguments.trim().length()  <= 0 && selections.size() <= 0)\r\n{\r\n\tresponse.put(\"text\",\"Please enter a file name to look for in OneDrive.\");\r\n\treturn response; \r\n}"
        }
      ]
    };
    var result = DidChangeTextDocumentParams.fromJsonFull(params);
  },skip: 'validation api change');

  test('repeated errors', () {
    //var parser = DgGrammarDef().build(start: DgGrammarDef().whitespaceLine) & prefix0.string('a');
    var input = """
    a = 1;
    a;


    //""";
    var result = parser.parse(input);
    assert(result.isSuccess);
    expect(result.value.length, 2);
    
  });
  //,skip: 'validation api change');

  test('check diagnostics 3', () {
    var result = DGParser.parse(SAMPLE4);
    List<Object> statements = result.value;
    Uri uri = Uri.parse('untitled:1');
    Sync.newLineTokens[uri] = ((char('\n') | char('\r') & char('\n').optional()) ).token().matchesSkipping(SAMPLE4);
    var validations = Validation.Validate(statements.cast<Node>(), uri);
    expect(validations, isEmpty);
  });



}
