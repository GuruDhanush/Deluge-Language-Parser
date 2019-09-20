import 'package:test/test.dart';
import 'lexer_test.dart' as lexer;
import 'parser_test.dart' as parser;
import 'hover_test.dart' as hover;
import 'validation_test.dart' as validation;
import 'symbols_test.dart' as symbol;
import 'codelens_test.dart' as codelens;

void main() {

  group('lexer', lexer.main);
  group('parser', parser.main);
  group('symbol', symbol.main);
  group('hover', hover.main);
  group('validation', validation.main);
  group('codelens', codelens.main);

}