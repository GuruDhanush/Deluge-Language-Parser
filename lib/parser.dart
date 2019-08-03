import 'package:DelugeDartParser/lexer.dart';
import 'package:DelugeDartParser/node.dart';
import 'package:petitparser/petitparser.dart';

DelugeParser ParserDG = DelugeParser();

class DelugeParser extends GrammarParser {
  DelugeParser() : super(DelugeParserDefinition());
}

class DelugeParserDefinition extends DgGrammarDef {
  Parser identifier() => super.identifier().map((id) => Identifier(id.value));

  Parser expression() => super
      .expression()
      .map((id) => DummyExpression(left: id[0], middle: id[1], right: id[2]));

  Parser bigintLiteral() => super
      .bigintLiteral()
      .map((id) => BigIntLiteral(value: id.value, raw: id.input));

  Parser decimalLiteral() => super
      .decimalLiteral()
      .map((id) => DecimalLiteral(value: id.value, raw: id.input));

  Parser stringLiteral() => super
      .stringLiteral()
      .map((id) => StringLiteral(value: id.value, raw: id.input));

  Parser booleanLiteral() => super.booleanLiteral().map(
      (id) => BooleanLiteral(value: id.value == 'true', raw: id.input));

  Parser binaryExpression() => super.binaryExpression().map((id) {
        var _tmpList = id[1];

        //case where we get an binary expression and next tokens tend to be zero.
        //useful in () expressions
        if (_tmpList.length == 0) return id[0];

        var bin = BinaryExpression(left: id[0]);

        for (var item in _tmpList) {
          if (item.length > 0) {
            if (bin.right != null) {
              bin = BinaryExpression(left: bin);
            }
            bin.oopertor = item[0].value;
            bin.right = item[1];
          }
        }
        return bin;
      });

  Parser bracketParam() => super
      .bracketParam()
      .map((id) => id[1]..extra.putIfAbsent('parentise', () => true));

  //Parser callExpression() => super.callExpression().map((id) => CallExpression(callee: id[0], arguments: id[1][1]));
  Parser callExpression() => super.callExpression().map((id) {
        var args = id[1][1];
        var params = [];
        for (var arg in args) {
          params.add(arg[0]);
        }
        return CallExpression(callee: id[0], arguments: params);
      });
  
  Parser memberExpression() => super.memberExpression().map((id) => MemberExpression(object: id[0], propery: id[2]));
}

class DummyExpression {
  Object left;
  Object right;
  Object middle;

  DummyExpression({this.left, this.middle, this.right});
}
