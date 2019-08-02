import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/parser.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:DelugeDartParser/lexer.dart';

void main() {
  DgGrammarDef dg;

  setUp(() {
    dg = DgGrammarDef();
  });

  group("single line comment", () {
    Parser parser;

    setUp(() {
      parser = dg.build(start: dg.SINGLELINE_COMMENT);
    });

    test('with new line', () {
      var input = "//Hello World\n";
      var result = parser.parse(input);

      expect(true, result.isSuccess);
      expect(null, result.message);
      expect([
        '/',
        '/',
        "Hello World".split(''),
        '\n',
      ], result.value);
    });
  });

  group("string", () {
    Parser parser;

    setUp(() {
      parser = dg.build(start: dg.STRING);
    });

    test("normal", () {
      var input = '"Hello World"';
      var result = parser.parse(input);
      expect(null, result.message);
      expect("Hello World".split(''), result.value);
      print(result);
    });
  });

  group("integer", () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.BIGINT);
    });

    test("-ve", () {
      var input = "-123";
      var result = parser.parse(input);

      expect(null, result.message);
      expect(-123, result.value);
      print(result);
    });

    test("normal", () {
      var input = "123";
      var result = parser.parse(input);

      expect(null, result.message);
      expect(123, result.value);
      print(result);
    });

    test("+ve", () {
      var input = "+123";
      var result = parser.parse(input);

      expect(null, result.message);
      expect(123, result.value);
      print(result);
    });
  });

  group("decimal", () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.DECIMAL);
    });

    test("-ve", () {
      var input = "-123.45";
      var result = parser.parse(input);

      expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);
    });

    test("normal", () {
      var input = "123.45";
      var result = parser.parse(input);

      expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);
    });

    test("leadingZero", () {
      var input = "0.";
      var result = parser.parse(input);

      expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);
    });

    test("onlyPoint", () {
      var input = ".45";
      var result = parser.parse(input);

      expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);
    });

    test("+ve", () {
      var input = "+123.45";
      var result = parser.parse(input);

      //expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);
    });
  });

  group("identifier", () {
    Parser parser;

    setUp(() {
      parser = dg.build(start: dg.identifier);
    });

    test("normal", () {
      var input = "id_num";
      var result = parser.parse(input);
      print(result.value);
      expect(true, result.isSuccess);
      //var n = result as Token;
      //print(n.)
    });

    test("with num", () {
      var input = "12_num";
      var result = parser.parse(input);

      expect(true, result.isFailure);
    });
  });

  group("if", () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.ifexpression);
    });

    test("if-normal", () {
      var input = "if(as = true) { as = false } else if(aa = false) { } ";
      var result = parser.parse(input);
      print(result);
      expect(true, result.isSuccess);
    },skip: "TODO: make logical expressions");
  });

  group("sysvars", () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.zohoSysVariables);
    });

    test("normal", () {
      var input = 'zoho.appname';
      expect(true, parser.accept(input));
    });

    test("typing for suggest", () {
      var input = 'zoho.cus';
      var result = parser.parse(input);
      expect(true, result.isFailure);
      print(result.message);
    });
  });

  group("list", () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.list);
    });

    test('block list', () {
      var input = '[1,2]';
      var result = parser.parse(input);
      print(result.value);
      assert(result.isSuccess);
    });

    test('swiggly list', () {
      var input = '{1,2,3}';
      var result = parser.parse(input);
      print(result.value);
      assert(result.isSuccess);
    });

    test('swiggly empty list', () {
      var input = '{}';
      var result = parser.parse(input);
      print(result.value);
      assert(result.isSuccess);
    });

    test('block empty list', () {
      var input = '[]';
      var result = parser.parse(input);
      print(result.value);
      assert(result.isSuccess);
    });
  });

  group("line", () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.qualified);
    });

    test('inital', () {
      //var input = 'params.put("select","name,webUrl,lastModifiedDateTime,file")';
      //var input = 'lastModifiedDate.getDay() + " " + lastModifiedDate.getDate().replaceFirst("(st|nd|rd|th)","").getAlpha() + " , " + year.subText(yearLength - 2,yearLength)';
      var input = 'hello.toString()';
      var result = parser.parse(input);
      print(result.message);
      //assert(result.isSuccess);
      var token = result.value[0] as Token;
      print(token);
    });
  });

  group('arithemtic', () {
    test('addition', () {
      Parser parser = dg.build(start: dg.arithmeticExpression);
      var result = parser.parse('1+2');
      assert(result.isSuccess);
      print(result.value);
    });

    test('substraction', () {
      Parser parser = dg.build(start: dg.arithmeticExpression);
      var result = parser.parse('1-2');
      assert(result.isSuccess);
      print(result.value);
    });

    test('add+sub', () {
      Parser parser = dg.build(start: dg.arithmeticExpression);
      var result = parser.parse('1+2-3');
      assert(result.isSuccess);
      print(result.value);
    });

    test("multiply", () {
      Parser parser = dg.build(start: dg.arithmeticExpression);
      var result = parser.parse('1+2-3*4');
      assert(result.isSuccess);
      print(result.value);
    });

    test('division', () {
      Parser parser = dg.build(start: dg.arithmeticExpression);
      var result = parser.parse('1+2-3*4/5');
      assert(result.isSuccess);
      print(result.value);
    });

    test('mod', () {
      Parser parser = dg.build(start: dg.arithmeticExpression);
      var result = parser.parse('1+2-3*4/5%6');
      assert(result.isSuccess);
      print(result.value);
    });

    test('brackets', () {
      Parser parser = dg.build(start: dg.arithmeticExpression);
//      var result = parser.parse('(1+2)-(3*4)/(5%6)');
      var result = parser.parse('(1+2)');
      assert(result.isSuccess);
      print(result.value);
    });

    test('identifiers', () {
      Parser parser = dg.build(start: dg.arithmeticExpression);
      var result = parser.parse('a.len() + b.len() + 3');
      assert(result.isSuccess);
      print(result.value);
    });
  });

  group('call expression', () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.callExpression);
    });

    test('normal', () {
      var result = parser.parse('map()');
      expect(true, result.isSuccess);
      expect('map', result.value[0][0].value);
      expect('(', result.value[1][0].value);
      expect(')', result.value[1][2].value);

      print(result.value);
    });

    test('with params', () {
      var result = parser.parse('map(identify, 1)');
      expect(true, result.isSuccess);
      expect('map', result.value[0][0].value);
      expect('(', result.value[1][0].value);
      expect(2, result.value[1][1].length);
      expect(')', result.value[1][2].value);

      print(result.value);
    });

    test('bigint params', () {
      var result = parser.parse('map(1,2,3)');
      expect(true, result.isSuccess);
      expect('map', result.value[0][0].value);
      expect('(', result.value[1][0].value);
      expect(3, result.value[1][1].length);
      expect(')', result.value[1][2].value);

      print(result.value);
    });
  });

  group('member expresion', () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.memberExpression);
    });

    test('normal', () {
      var result = parser.parse('hello.length');

      expect('hello', result.value[0][0].value);
      expect('.', result.value[1].value);
      expect('length', result.value[2][0].value);

    });
  });
}
