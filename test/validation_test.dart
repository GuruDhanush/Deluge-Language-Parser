import 'package:DelugeDartParser/parser/lexer.dart';
import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/parser/parser.dart';
import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/lsp/messaging/diagnostics.dart';
import 'package:DelugeDartParser/server/validation/validation.dart';
import 'package:DelugeDartParser/web/server.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

import 'example/sample1.dart';

void main() {
  Parser parser;
  Parser newLineParser;
  setUp(() {
    parser = DelugeParser();
    newLineParser = Token.newlineParser().token();
  });

  test('for inner error', () {
    var input = """
    for each i in list {
      a;
    }
    """;
    var statements = parser.parse(input).value;
    var newLineTokens = newLineParser.matchesSkipping(input);
    var diag = ValidationServer.validate(statements, newLineTokens);

    expect(diag.length, 1);
  });

  test('for test error', () {
    var input = """
    for each i in list 
      a;
    }
    """;
    var result = parser.parse(input);
    assert(result.isFailure);
  });

  test('if inner error', () {
    var input = """
    if(true) {
      a;
    }
    """;
    var statements = parser.parse(input).value;
    var newLineTokens = newLineParser.matchesSkipping(input);
    var diag = ValidationServer.validate(statements, newLineTokens);

    expect(diag.length, 1);
  });

  test('if test error', () {
    var input = """
    if(a) 
      a = 1;
    }
    """;
    var result = parser.parse(input);
    assert(result.isFailure);
  });

  group('no semicolon all', () {
    final input = "a = 1";
    final uri = Uri.parse('file://1');
    var statements;
    var newLineTokens;

    setUp(() {
      statements = DelugeParser().parse(input).value;
      newLineTokens = Token.newlineParser().token().matchesSkipping(input);
    });

    test('server', () {
      var diag = ValidationServer.validate(statements, newLineTokens);

      expect(diag.length, 1);
      var range = diag.first.range;
      expect(range.end.character - range.start.character, 5);
    });

    test('web', () {
      var server = WebServer();
      server.newLineTokens = newLineTokens;
      server.statements = statements;

      var results = server.computeDiagnostics();

      expect(results.length, 1);
      expect(
          results.first,
          equals({
            'startLineNumber': 1,
            'startColumn': 1,
            'endLineNumber': 1,
            'endColumn': 6,
            'message': "Illegal line",
            'severity': 8
          }));
    });
  });

  test('continuation parser', () {
    var input = "[1a3,2]";
    //var parser = char('[') & digit().plus().separatedBy(char(','), includeSeparators: false) & char(']');
    // var parser = (char('[') & digit() & char(',') & digit() & char(']')) |
    // char('{') & digit() & char(',') & digit() & char('}') ;
    var parser =
        ParserDefinition().build(start: ParserDefinition().listExpression);
    var level = 0;
    var modParser = transformParser(parser, (each) {
      if (each is ActionParser) {
        print(1);
      }
      return ContinuationParser(each, (continuation, context) {
        print('${'  ' * level}$each');
        level++;
        final result = continuation(context);
        level--;
        if (result.isFailure && result.message.contains('","')) {
          var modResult =
              (noneOf(',').plus() & char(',')).flatten().parseOn(context);
          print('${'  ' * level} --our  $modResult');
          if (modResult.isSuccess) {
            return modResult;
          }
        }
        if (false &&
            result is Failure &&
            each is! TrimmingParser &&
            each is CharacterParser &&
            each.predicate is! WhitespaceCharPredicate) {
          print('$level, ${result.message}');
        }
        print('${'  ' * level}$result');
        return result;
      });
    });
    var result = modParser.parse(input);
    assert(result.isSuccess);
  }, skip: 'testing on new implementations, ignore');
}
