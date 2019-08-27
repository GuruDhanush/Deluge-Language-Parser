import 'dart:convert';
import 'dart:io';

import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/parser.dart';
import 'package:DelugeDartParser/server/docs/docs.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/language/codelens.dart';
import 'package:DelugeDartParser/server/language/hover.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

import 'example/sample1.dart';

void main() {
  DelugeParser parser;
  setUp(() {
    parser = DelugeParser();
  });

  test('simple parse', () {
    var input = SAMPLE3;
    var result = parser.parse(input);
    var exp = result.value;
    var pos = Loc(line: 1, column: 4);

    var node;
    int first = 0;
    int last = exp.length - 1;
    while (first <= last) {
      int middle = (first + (last - 1) / 2).toInt();

      var location = exp[middle].isInside(pos);
      if (location == 0) {
        node = exp[middle];
      } else if (location < 0) {
        first = middle + 1;
      } else {
        last = middle - 1;
      }
    }

    print(node);
  }, skip: 'not used');

  test('identifier = datatype', () {
    var input = "word = 1234;";
    var result = parser.parse(input);
    var exp = ((result.value[0] as ExpressionStatement).expression as List)[0];
    var assExp = exp as AssignmentExpression;
    assert(result.isSuccess);
  });

  test('identifier = method', () {
    var input = "word = resp.get(1,2);";
    var result = parser.parse(input);

    var exp = ((result.value[0] as ExpressionStatement).expression as List)[0];
    var assExp = exp as AssignmentExpression;
    assert(result.isSuccess);
  });

  test('multiple lines', () {
    var input = """
    a = resp.get(1);
    resp.put(1, "Hello");
    // hi
    """;
    var result = parser.parse(input);

    assert(result.isSuccess);
  });

  test('tree traverse', () {
    var result = parser.parse(SAMPLE3);
    var testPos = Loc(line: 5, column: 14);
    //var hoverResult = HoverProvider.treeTraverse(testPos, result.value);
    //expect(hoverResult, isNotNull);
  });

  test('load yaml file', () async {
    // YamlMap doc = loadYaml(
    //     (await File('./lib/docs/datatypes/string.yaml').readAsString()));
    // print(doc['examples']);

    //print(Directory.current. );

    String homePath;
    if(Platform.isWindows) {
      homePath = Platform.environment['USERPROFILE'];
    }
    else {
      homePath = Platform.environment[''];
    }

    var s = Platform.environment['USERPROFILE'];
    print(s);
    
  });

  test('bintoString test', () {
    var parser = DelugeParserDefinition().build(start: DelugeParserDefinition().binaryExpression).end();
    // var input = """ "Hello" + something() + "Hi" + hi""";
    var input = """ "<div>"  + zoho.url + "Ho&nbsp;<span class='font' style='font-family: \\"times new roman\\", times, serif, sans-serif;'> Heiisds&nbsp;<span class='highlight' style='background-color:#ff66fe'> asasdsadasd</span><span class='highlight' style='background-color:#ffffff'>​&nbsp;</span></span><br></div>" """;
    var result = parser.parse(input);
    assert(result.isSuccess);

    String data = CodeLensProvider.ConvertBinaryToString(result.value);
    expect(data, isNotEmpty);

    
  });

  test('load doc', () async {
    var docFile = File(p.join(Util.homeDir(), 'deluge-vscode', 'docs.json'));
    var docs = (json.decode(await docFile.readAsString()) as Map)['functions'];
    expect(docs, isNotEmpty);
  });

  test('search doc', () async {
    await Docs.fetchDocs();
    var putDoc = Docs.searchDoc('trim');
    expect(putDoc, isNotEmpty);
  });

  test('new line token test', () {

    var input = """ 
    Hello
    Hi
    Bye
    """;
    var result = Token.newlineParser().token().matchesSkipping(input);
    assert(result.isNotEmpty);
    
  });


  test('find pos test', () {

    var input = """
    Hello = 1;
    World = 2;
    Bye = 3;
    """;
    var result = parser.parse(input);
    var loc = Loc(line: 2, column: 3);
    var newLineTokens =  ((char('\n') | char('\r') & char('\n').optional()) ).token().matchesSkipping(input);
    var line = newLineTokens[loc.line-2];
    var pos = line.stop + loc.column;


    
  });


}
