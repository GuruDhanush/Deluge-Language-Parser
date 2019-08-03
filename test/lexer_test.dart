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

  group('multi line comment', () {

    Parser parser;
    setUp((){
      parser = dg.build(start: dg.MULTILINE_COMMENT);
    });

    test('normal', () {
      var input = '/* Hello  */';
      var result = parser.parse(input);
      assert(result.isSuccess);
      expect('/', result.value[0]);
      expect('*', result.value[1]);
      expect(input.length-4, result.value[2].length);
      expect('*', result.value[3]);
      expect('/', result.value[4]);
    });
    
    
    test('with new lines', () {
      var input = '/* Hello \n  Hi \n Bye  */';
      var result = parser.parse(input);
      assert(result.isSuccess);
      expect('/', result.value[0]);
      expect('*', result.value[1]);
      expect(input.length-4, result.value[2].length);
      expect('*', result.value[3]);
      expect('/', result.value[4]);
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

  group('boolean', () {
    
    Parser parser;
    setUp((){
      parser = dg.build(start: dg.booleanLiteral);
    });

    test('true', (){
      var result = parser.parse('true');
      expect(true, result.isSuccess);
      expect('true', result.value.value);
    });

    test('false', (){
      var result = parser.parse('false');
      expect(true, result.isSuccess);
      expect('false', result.value.value);
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

  group('binary expression', () {

    Parser parser;
    setUp((){
      parser = dg.build(start: dg.binaryExpression);
    });

  test('addition', () {
      var result = parser.parse('1+2');
      assert(result.isSuccess);
      print(result.value);
    },tags: 'flaky');

    test('substraction', () {
      var result = parser.parse('1-2');
      assert(result.isSuccess);
      print(result.value);
    },tags: 'flaky');

    test('add+sub', () {
      var result = parser.parse('1+2-3');
      assert(result.isSuccess);
      print(result.value);
    },tags: 'flaky');

    test("multiply", () {
      var result = parser.parse('1+2-3*4');
      assert(result.isSuccess);
      print(result.value);
    },tags: 'flaky');

    test('division', () {
      var result = parser.parse('1+2-3*4/5');
      assert(result.isSuccess);
      print(result.value);
    },tags: 'flaky');

    test('mod', () {
      var result = parser.parse('1+2-3*4/5%6');
      assert(result.isSuccess);
      print(result.value);
    },tags: 'flaky');

    test('brackets', () {
//      var result = parser.parse('(1+2)-(3*4)/(5%6)');
      var result = parser.parse('(1+2)');
      assert(result.isSuccess);
      print(result.value);
    },tags: 'flaky');

    test('identifiers', () {
      var result = parser.parse('a.len() + b.len() + 3');
      assert(result.isSuccess);
      print(result.value);
    },tags: 'flaky');

    test('equality', (){
      var result = parser.parse('1 == 2');
      assert(result.isSuccess);

      expect(1, result.value[0].value);
      expect('==', result.value[1][0][0].value);
      expect(2, result.value[1][0][1].value);
    });

    test('relational', () {
      var result = parser.parse('1 <= 2');
      assert(result.isSuccess);
      expect(1, result.value[0].value);
      expect('<=', result.value[1][0][0].value);
      expect(2, result.value[1][0][1].value);    
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

  group('object expression', (){


  });

  group('Assignment expression', () {
    
    Parser parser;
    setUp((){
      parser = dg.build(start: dg.assignmentExpression);
    });

    test('identifier = identifer', () {
      
      var result = parser.parse('hello = hi;');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect('hi', result.value[2][0].value);
      expect(';', result.value[3].value);
    });

    test('identifier = literal (int)', () {
      
      var result = parser.parse('hello = 12;');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect(12, result.value[2][0].value);
      expect(';', result.value[3].value);
    
    });

    test('identifier = literal (decimal)', () {
      
      var result = parser.parse('hello = 1.2;');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect(1.2, result.value[2][0].value);
      expect(';', result.value[3].value);
    
    });

    test('identifier = literal (string)', () {
      
      var result = parser.parse('hello = "hi";');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect('hi'.split(''), result.value[2][0].value);
      expect(';', result.value[3].value);
    
    });

    test('identifier = literal (bool)', () {
      
      var result = parser.parse('hello = true;');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect('true', result.value[2][0].value);
      expect(';', result.value[3].value);
    
    });

    test('increment by 1', (){
      var result = parser.parse('i +=1;');

      expect(true, result.isSuccess);
      expect('i', result.value[0].value);
      expect('+=', result.value[1].value);
      expect(1, result.value[2][0].value);
      expect(';', result.value[3].value);
    });

    test('increment with an member expression', () {
      
      var result = parser.parse('i += list.length;');

      expect(true, result.isSuccess);
      expect('i', result.value[0].value);
      expect('+=', result.value[1].value);
      expect('list', result.value[2][0][0].value);
      expect('length', result.value[2][2][0].value);
      expect(';', result.value[3].value);

    });

    test('increment with an call expression', () {
      
      var result = parser.parse('i += list.get(1);');

      expect(true, result.isSuccess);
      expect('i', result.value[0].value);
      expect('+=', result.value[1].value);
      expect('list', result.value[2][0][0][0].value);
      expect('get', result.value[2][0][2][0].value);
      expect(1, result.value[2][1][1][0][0][0].value);
      expect(';', result.value[3].value);

    });

  });

  group('Logical expression ', () {

    Parser parser;
    setUp((){
      parser = dg.build(start: dg.logicalExpression);
    });

    test('identifier && identifer', () {
      var result = parser.parse('a && b');

      assert(result.isSuccess);
      expect('a', result.value[0][0].value);
      expect('&&', result.value[1][0][0].value);
      expect('b', result.value[1][0][1][0].value);
    });

    
    test('int || int', () {
      var result = parser.parse('1 || 2');

      assert(result.isSuccess);
      expect(1, result.value[0][0].value);
      expect('||', result.value[1][0][0].value);
      expect(2, result.value[1][0][1][0].value);
    });

    test('member expression || call expression', () {
      var result = parser.parse('map.length && map.get()');

      assert(result.isSuccess);
      
    });

  });
}
