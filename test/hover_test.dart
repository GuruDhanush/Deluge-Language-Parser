import 'dart:io';

import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/parser.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/language/hover.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

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
    var hoverResult = HoverProvider.treeTraverse(testPos, result.value);
    expect(hoverResult, isNotNull);
  });

  test('load yaml file', () async {
    // YamlMap doc = loadYaml(
    //     (await File('./lib/docs/datatypes/string.yaml').readAsString()));
    // print(doc['examples']);

    //print(Directory.current. );
    
  });
}
