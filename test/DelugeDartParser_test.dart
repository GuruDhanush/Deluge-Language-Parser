import 'dart:ffi';

import 'package:DelugeDartParser/DelugeDartParser.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
//import 'package:petitparser/petitparser.dart';


void main() {

  DgGrammarDef dg;

  setUp(() {
    dg = DgGrammarDef();

  });



  group("single line comment", (){

    Parser parser;

    setUp((){
        parser = dg.build(start: dg.SINGLELINE_COMMENT);
    });


    test('with new line', () {
      var input = "//Hello World\n";
      var result = parser.parse(input);

      expect(true, result.isSuccess);
      expect(null, result.message);
      expect(['/', '/', "Hello World".split(''), '\n',] , result.value);

    });

  });

  group("string", (){

    Parser parser;

    setUp((){
      parser = dg.build(start: dg.STRING);
    });

    test("normal", (){
      var input = '"Hello World"';
      var result = parser.parse(input);
      expect(null, result.message);
      expect(['"', "Hello World".split(''), '"'], result.value);
      print(result);
    });

  });

  group("integer", () {

    Parser parser;
    setUp((){
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

  });

  group("decimal", () {

    Parser parser;
    setUp((){
      parser = dg.build(start: dg.DECIMAL);
    });

    test("-ve", (){
      var input = "-123.45";
      var result = parser.parse(input);
      
      expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);
    });

    test("normal", (){
      var input = "123.45";
      var result = parser.parse(input);
      
      expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);

    });

    test("leadingZero", (){

      var input = "0.";
      var result = parser.parse(input);
      
      expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);

    });

    test("onlyPoint", (){
      var input = ".45";
      var result = parser.parse(input);
      
      expect(null, result.message);
      expect(double.parse(input), result.value);
      print(result);
    });

  });
 
  group("identifier", (){
    Parser parser;

    setUp((){
      parser = dg.build(start: dg.IDENTIFIER);
    });

    test("normal", (){
      var input = "id_num";
      var result = parser.parse(input);

      expect(true, result.isSuccess);
    });

    test("with num", (){
      var input = "12_num";
      var result = parser.parse(input);

      expect(true, result.isFailure);
    });

  });

  group("if", (){

    Parser parser;
    setUp((){
      parser = dg.build(start: dg.ifexpression);
    });

    test("if-normal", (){
      var input = "if(as = true) { as = false } else if(aa = false) { } ";
      var result = parser.parse(input);
    
      expect(true, result.isSuccess);
      print("$result");
    });

  });
}

