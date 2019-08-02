import 'package:test/test.dart';
import 'lexer_test.dart' as lexer;
import 'parser_test.dart' as parser;

//some how adding _test to file names is picking up the code lens for test

void main() {


  group('lexer', lexer.main);
  group('parser', parser.main);

}