import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/parser.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:DelugeDartParser/lexer.dart';
import './example/sample1.dart' as sample;

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

    test('with escape chars', (){
      parser = dg.build(start: dg.start);
      var input = """ 
      //response.put("text",createdBy + " \nLast Modified on " + lastModifiedDate + " \n");
      card = Map();
      """;
      var result = parser.parse(input);

      assert(result.isSuccess);
      expect(input.length, result.position);
    }, skip: 'fails due to improper line comment implementation.');
  
  });

  group('multi line comment', () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.MULTILINE_COMMENT);
    });

    test('normal', () {
      var input = '/* Hello  */';
      var result = parser.parse(input);
      assert(result.isSuccess);
      expect('/', result.value[0]);
      expect('*', result.value[1]);
      expect(input.length - 4, result.value[2].length);
      expect('*', result.value[3]);
      expect('/', result.value[4]);
    });

    test('with new lines', () {
      var input = '/* Hello \n  Hi \n Bye  */';
      var result = parser.parse(input);
      assert(result.isSuccess);
      expect('/', result.value[0]);
      expect('*', result.value[1]);
      expect(input.length - 4, result.value[2].length);
      expect('*', result.value[3]);
      expect('/', result.value[4]);
    });

    test('nested multi line comments', (){

      var input = """/* 
        This is a comment
        /*
          THis is a nested comment
        */
      */""";
      var result = parser.parse(input);
      assert(result.isSuccess);
      expect(input.length, result.position);
    });
  });

  group("string", () {
    Parser parser;

    setUp(() {
      parser = dg.build(start: dg.STRING).end();
    });

    test("normal", () {
      var input = '"Hello World"';
      var result = parser.parse(input);
      expect(null, result.message);
      expect("Hello World".split(''), result.value[1]);
    });

    test('with escape chars', () {
      var input = '"Hello \\n \\" Hi "';
      var result = parser.parse(input);
      assert(result.isSuccess);
      // one -2 for two end punctuations and other 2 to account for extra \ removed by dart
      expect(input.length-2-2, result.value[1].length);
    });

    test('string inner content - not accept', () {
      var result = parser.parse('"""');
      assert(result.isFailure);
    });

    test('string inner content - accept', () {
      var result = parser.parse('"\\""');
      assert(result.isSuccess);
      expect('\\"', result.value[1][0]);
    });

    test('with unicode chars', () {
      var input = '"hello 👍."';
      var result = parser.parse(input);

      assert(result.isSuccess);
      expect(input.length, result.position);
      
    });

    test('with '' quotes', () {
      var input = "'Hello World'";
      var result = parser.parse(input);
      assert(result.isSuccess);
      expect(input.split('').sublist(1, input.length-1), result.value[1]);
    });

    test('with '' quotes & escape chars', () {
      var input = "'Hello \\' \n World'";
      var result = parser.parse(input);
      assert(result.isSuccess);
      expect(input.length, result.position);
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
    setUp(() {
      parser = dg.build(start: dg.booleanLiteral);
    });

    test('true', () {
      var result = parser.parse('true');
      expect(true, result.isSuccess);
      expect('true', result.value.value);
    });

    test('false', () {
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
      parser = dg.build(start: dg.ifStatement);
    });

    test("if-normal", () {
      var input = """
        if(true) {
          as = false;
        }
      """;
      var result = parser.parse(input);
      print(result);
      expect(true, result.isSuccess);
      expect(input.length, result.position);
    });
  });

  group('for', () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.forStatement);
    });

    test('For simple', () {
      var input = """ 
        for each i in k.getList() {
            k = i;
        }
      """;
      var result = parser.parse(input);

      assert(result.isSuccess);
      expect(input.length, result.position);
    });
  });

  //TODO: removed since there is a possibility of moving sysvar to analysis
  // group("sysvars", () {
  //   Parser parser;
  //   setUp(() {
  //     parser = dg.build(start: dg.zohoSysVariables);
  //   });

  //   test("normal", () {
  //     var input = 'zoho.appname';
  //     expect(true, parser.accept(input));
  //   });

  //   test("typing for suggest", () {
  //     var input = 'zoho.cus';
  //     var result = parser.parse(input);
  //     expect(true, result.isFailure);
  //     print(result.message);
  //   });
  // });

  group('list declaration', () {
    Parser parser;
    setUp((){
     parser = dg.build(start: dg.listDeclaration).end();
    });

    test('empty list', () {
      var result = parser.parse('List()');
      assert(result.isSuccess);
    });

    test('list with an string data type', () {
      var result = parser.parse('List:String()');
      assert(result.isSuccess);
    });

    test('with an list in constructor', () {
      var result = parser.parse('List:Int({1,2,3})');
      assert(result.isSuccess);
    });
  });

   group('Collection declaration', () {
    Parser parser;
    setUp((){
     parser = dg.build(start: dg.collectionDeclaration).end();
    });

    test('empty collection', () {
      var result = parser.parse('Collection()');
      assert(result.isSuccess);
    });

    test('collection with list', () {
      var result = parser.parse('Collection(1,2,3)');
      assert(result.isSuccess);
    });

    test('collection with an map', () {
      var result = parser.parse('Collection("Name": "Jane", "Age": 21)');
      assert(result.isSuccess);
    });
  });




  group("list expression", () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.listExpression);
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
    //,skip: 'yet to be supported');

    test('swiggly empty list', () {
      var input = '{}';
      var result = parser.parse(input);
      print(result.value);
      assert(result.isSuccess);
    });
    //,skip: 'yet to be supported');

    test('block empty list', () {
      var input = '[]';
      var result = parser.parse(input);
      print(result.value);
      assert(result.isSuccess);
    });

    test('differentiate list and map - list', () {
      var parser =  dg.build(start: dg.singleParam).end();
      var result = parser.parse('{1,2,3}');
      assert(result.isSuccess);
    });

    test('differentiate list and map - map', () {
      var parser =  dg.build(start: dg.singleParam).end();
      var result = parser.parse('{"name": "jane", "age": 21}');
      assert(result.isSuccess);
    });
    



  });

  group("line", () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.callExpression);
    });

    test('inital', () {
      //var input = 'params.put("select","name,webUrl,lastModifiedDateTime,file")';
      //var input = 'lastModifiedDate.getDay() + " " + lastModifiedDate.getDate().replaceFirst("(st|nd|rd|th)","").getAlpha() + " , " + year.subText(yearLength - 2,yearLength)';
      var input = 'hello.toString()';
      var result = parser.parse(input);
      assert(result.isSuccess);
      //print(result.message);
      //assert(result.isSuccess);
      //var token = result.value[0] as Token;
      //print(token);
    });
  });

  group('binary expression', () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.binaryExpression);
    });

    test('addition', () {
      var result = parser.parse('1+2');
      assert(result.isSuccess);
      expect(1, result.value[0].value);
      expect('+', result.value[1][0][0].value);
      expect(2, result.value[1][0][1].value);
    });

    test('substraction', () {
      var result = parser.parse('1-2');
      assert(result.isSuccess);
      expect(1, result.value[0].value);
      expect('-', result.value[1][0][0].value);
      expect(2, result.value[1][0][1].value);
    });

    test('add+sub', () {
      var result = parser.parse('1+2-3');
      assert(result.isSuccess);
      expect(1, result.value[0].value);
      expect('+', result.value[1][0][0].value);
      expect(2, result.value[1][0][1].value);
      expect('-', result.value[1][1][0].value);
      expect(3, result.value[1][1][1].value);
    });

    test("multiply", () {
      var result = parser.parse('1+2-3*4');
      assert(result.isSuccess);
      expect(1, result.value[0].value);
      expect('+', result.value[1][0][0].value);
      expect(2, result.value[1][0][1].value);
      expect('-', result.value[1][1][0].value);
      expect(3, result.value[1][1][1].value);
      expect('*', result.value[1][2][0].value);
      expect(4, result.value[1][2][1].value);
    });

    test('division', () {
      var result = parser.parse('1+2-3*4/5');
      assert(result.isSuccess);
      expect(1, result.value[0].value);
      expect('+', result.value[1][0][0].value);
      expect(2, result.value[1][0][1].value);
      expect('-', result.value[1][1][0].value);
      expect(3, result.value[1][1][1].value);
      expect('*', result.value[1][2][0].value);
      expect(4, result.value[1][2][1].value);
      expect('/', result.value[1][3][0].value);
      expect(5, result.value[1][3][1].value);
    });

    test('mod', () {
      var result = parser.parse('1+2-3*4/5%6');
      assert(result.isSuccess);
      expect(1, result.value[0].value);
      expect('+', result.value[1][0][0].value);
      expect(2, result.value[1][0][1].value);
      expect('-', result.value[1][1][0].value);
      expect(3, result.value[1][1][1].value);
      expect('*', result.value[1][2][0].value);
      expect(4, result.value[1][2][1].value);
      expect('/', result.value[1][3][0].value);
      expect(5, result.value[1][3][1].value);
      expect('%', result.value[1][4][0].value);
      expect(6, result.value[1][4][1].value);
    });

    test('brackets', () {
      var result = parser.parse('(1+2)');
      assert(result.isSuccess);
      expect('(', result.value[0][0].value);
      expect(1, result.value[0][1][0].value);
      expect('+', result.value[0][1][1][0][0].value);
      expect(2, result.value[0][1][1][0][1].value);
      expect(')', result.value[0][2].value);
    });

    test('member expressions', () {
      var result = parser.parse('a.len + b.len + c.len');

      assert(result.isSuccess);
      expect('a', result.value[0][0].value);
      expect('len', result.value[0][2].value);
      expect('b', result.value[1][0][1][0].value);
      expect('len', result.value[1][0][1][2].value);
      expect('c', result.value[1][1][1][0].value);
      expect('len', result.value[1][1][1][2].value);
    });

    test('equality', () {
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

    test('with call expressions', () {
      var result = parser.parse('a.len() + c.len + 2');
      assert(result.isSuccess);

      expect('a', result.value[0][0][0].value);
      expect('len', result.value[0][0][2].value);
      expect('+', result.value[1][0][0].value);
      expect('c', result.value[1][0][1][0].value);
      expect('len', result.value[1][0][1][2].value);
      expect('+', result.value[1][1][0].value);
      expect(2, result.value[1][1][1].value);
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
      expect('map', result.value[0].value);
      expect('(', result.value[1][0].value);
      expect(')', result.value[1][2].value);

      print(result.value);
    });

    test('with params', () {
      var result = parser.parse('map(identify, 1)');
      expect(true, result.isSuccess);
      expect('map', result.value[0].value);
      expect('(', result.value[1][0].value);
      expect(2, result.value[1][1].length);
      expect(')', result.value[1][2].value);

      print(result.value);
    });

    test('bigint params', () {
      var result = parser.parse('map(1,2,3)');
      expect(true, result.isSuccess);
      expect('map', result.value[0].value);
      expect('(', result.value[1][0].value);
      expect(3, result.value[1][1].length);
      expect(')', result.value[1][2].value);

      print(result.value);
    });

    test('nested in call', () {
      //arguments.trim().length()
      var result = parser.parse('a.b().c()');

      assert(result.isSuccess);
      expect('a', result.value[0][0].value);
      expect('b', result.value[0][2].value);
      expect('(', result.value[1][0].value);
      expect(')', result.value[1][2].value);
      expect('c', result.value[2][0][1].value);
      expect('(', result.value[2][0][2][0].value);
      expect(')', result.value[2][0][2][2].value);
    });
  });

  group('member expresion', () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.memberExpression);
    });

    test('normal', () {
      var result = parser.parse('hello.length');

      expect('hello', result.value[0].value);
      expect('.', result.value[1].value);
      expect('length', result.value[2].value);
    });

    test('nested', () {
      var result = parser.parse('a.b.c');
      assert(result.isSuccess);
      expect('a', result.value[0].value);
      expect('b', result.value[2].value);
      expect('c', result.value[3][0][1].value);
    });
  });

  group('object expression', () {});

  group('Assignment expression', () {
    Parser parser;
    setUp(() {
      parser = dg.build(start: dg.assignmentExpression);
    });

    test('identifier = identifer', () {
      var result = parser.parse('hello = hi');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect('hi', result.value[2][0].value);
    });

    test('identifier = literal (int)', () {
      var result = parser.parse('hello = 12');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect(12, result.value[2][0].value);
    });

    test('identifier = literal (decimal)', () {
      var result = parser.parse('hello = 1.2');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect(1.2, result.value[2][0].value);
    });

    test('identifier = literal (string)', () {
      var result = parser.parse('hello = "hi"');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect('hi'.split(''), result.value[2][0].value[1]);
    });

    test('identifier = literal (bool)', () {
      var result = parser.parse('hello = true');
      expect(true, result.isSuccess);
      expect('hello', result.value[0].value);
      expect('=', result.value[1].value);
      expect('true', result.value[2][0].value);
    });

    test('increment by 1', () {
      var result = parser.parse('i +=1');

      expect(true, result.isSuccess);
      expect('i', result.value[0].value);
      expect('+=', result.value[1].value);
      expect(1, result.value[2][0].value);
    });

    test('increment with an member expression', () {
      var result = parser.parse('i += list.length');

      expect(true, result.isSuccess);
      expect('i', result.value[0].value);
      expect('+=', result.value[1].value);
      expect('list', result.value[2][0].value);
      expect('length', result.value[2][2].value);
    });

    test('increment with an call expression', () {
      var result = parser.parse('i += list.get(1)');

      expect(true, result.isSuccess);
      expect('i', result.value[0].value);
      expect('+=', result.value[1].value);
      expect('list', result.value[2][0][0][0][0].value);
      expect('get', result.value[2][0][0][2].value);
      expect(1, result.value[2][0][0][1][1][0][0].value);
    });
  

  },skip: 'yet to be updated');

  group('Logical expression ', () {
    Parser parser;
    setUp(() {
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
      expect('map', result.value[0][0][0].value);
      expect('length', result.value[0][0][2].value);
      expect('&&', result.value[1][0][0].value);
      expect('map', result.value[1][0][1][0][0][0].value);
      expect('get', result.value[1][0][1][0][0][2].value);
    });

    test('&& with call expression', () {
      var result = parser
          .parse('arguments.trim().length() <= 0 && selections.size() <= 0');

      assert(result.isSuccess);
      expect('arguments', result.value[0][0][0][0].value);
      expect('trim', result.value[0][0][0][2].value);
      expect('length', result.value[0][0][2][0][1].value);
      expect(0, result.value[0][1][0][1].value);
      expect('&&', result.value[1][0][0].value);
      expect('selections', result.value[1][0][1][0][0][0].value);
      expect('size', result.value[1][0][1][0][0][2].value);
      expect('<=', result.value[1][0][1][1][0][0].value);
      expect(0, result.value[1][0][1][1][0][1].value);
    });
  });


  test('unary expression', () {
    var parser = dg.build(start: dg.singleParam);
    var result = parser.parse('!1');
    assert(result.isSuccess);
    expect('!', result.value[0].value);
    expect(1, result.value[1].value);
  });

   group('invoke func', () {
    Parser parser;
    setUp((){
      parser = dg.build(start: dg.invokeFunction);
    });

    test('normal', () {
      var input = """ 
      invokeUrl
      [
        url: "www.google.com"
        type: GET
      ];
      """;
      var result = parser.parse(input);
      assert(result.isSuccess);
    });
  });


  test('tmp test', () {
    
    //var parser = DgGrammarDef().build(start: DgGrammarDef().ifStatement);
    var parser = DgGrammar();
    var input = sample.SAMPLE1; 
    var watch = Stopwatch() ..start();
    var result = parser.parse(input);
    watch.stop();
    print('elapsed time ${watch.elapsedMilliseconds}');
    expect(input.length, result.position);
  });

  test('test-bed', () {
    //var input = 'response.put("text",createdBy + " \nLast Modified on " + lastModifiedDate + " \n");';
    //var input = 'createdBy + " \nLast Modified on " + lastModifiedDate + " \n"';
    var input = '!1';
    var parser = dg.build(start: dg.singleParam);
    var result = parser.parse(input);
    assert(result.isSuccess);

  });

}
