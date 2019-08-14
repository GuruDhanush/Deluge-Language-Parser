import 'package:DelugeDartParser/lexer.dart';
import 'package:DelugeDartParser/node.dart';
import 'package:petitparser/petitparser.dart';

DelugeParser ParserDG = DelugeParser();

class DelugeParser extends GrammarParser {
  DelugeParser() : super(DelugeParserDefinition());
}

class DelugeParserDefinition extends DgGrammarDef {
  Parser identifier() => super.identifier().map((id) => Identifier(id.value));

  Parser bigintLiteral() => super
      .bigintLiteral()
      .map((id) => BigIntLiteral(value: id.value, raw: id.input));

  Parser decimalLiteral() => super
      .decimalLiteral()
      .map((id) => DecimalLiteral(value: id.value, raw: id.input));

  Parser stringLiteral() => super
      .stringLiteral()
      .map((id) => StringLiteral(value: id.value, raw: id.input));

  Parser booleanLiteral() => super
      .booleanLiteral()
      .map((id) => BooleanLiteral(value: id.value == 'true', raw: id.input));

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

  Parser logicalExpression() => super.logicalExpression().map((id) {
        var _tmpList = id[1];

        //case where we get an logical expression and next tokens tend to be zero.
        //useful in () expressions
        if (_tmpList.length == 0) return id[0];

        var bin = LogicalExpression(left: id[0]);

        for (var item in _tmpList) {
          if (item.length > 0) {
            if (bin.right != null) {
              bin = LogicalExpression(left: bin);
            }
            bin.oopertor = item[0].value;
            bin.right = item[1];
          }
        }
        return bin;
      });

  Parser bracketExpression() => super
      .bracketExpression()
      .map((id) => id[1]..extra.putIfAbsent('parentise', () => true));

  //Parser callExpression() => super.callExpression().map((id) => CallExpression(callee: id[0], arguments: id[1][1]));
  Parser callExpression() => super.callExpression().map((id) {
        var args = id[1][1];
        var params = [];
        for (var arg in args) {
          params.add(arg);
        }
        Object exp = CallExpression(callee: id[0], arguments: params);
        for (var item in id[2]) {
          exp = MemberExpression(object: exp, propery: item[1]);

          //dealing with call expression
          if (item[2] != null) {
            exp = CallExpression(callee: exp, arguments: item[2][1]);
          }
        }
        return exp;
      });

  Parser memberExpression() => super.memberExpression().map((id) {
        Object exp = MemberExpression(object: id[0], propery: id[2]);
        for (var item in id[3]) {
          exp = MemberExpression(object: exp, propery: item[1]);
          if (item[2] != null) {
            exp = CallExpression(callee: exp, arguments: item[2][1]);
          }
        }
        return exp;
      });

  Parser expressionStatement() => super.expressionStatement().map((id) {
        return ExpressionStatement(expression: id);
      });

  Parser returnStatement() =>
      super.returnStatement().map((id) => ReturnStatement(argument: id[1]));

  Parser infoExpression() =>
      super.infoExpression().map((id) => InfoExpression(argument: id[1]));

  Parser assignmentExpression() => super.assignmentExpression().map((id) =>
      AssignmentExpression(left: id[0], ooperator: id[1].value, right: id[2]));

  Parser unaryExpression() => super
      .unaryExpression()
      .map((id) => UnaryExpression(expression: id[1], ooperator: id[0].value));

  Parser ifExpression() => super
      .ifExpression()
      .map((id) => IfExpression(test: id[2], value: id[4], alternate: id[6]));

  Parser ifNullExpression() => super
      .ifNullExpression()
      .map((id) => IfNullExpression(value: id[2], alternate: id[4]));

  Parser blockStatement() =>
      super.blockStatement().map((id) => BlockStatement(body: id[1]));

  Parser ifStatement() => super.ifStatement().map((id) {
        var consequent = id[6] != null ? id[6][1] : null;
        var turns = id[5];
        for (var i = 0; i < turns.length; i++) {
          var item = turns[i];
          consequent = IfStatement(
              test: item[3], consequent: item[5], alternate: consequent);
        }
        return IfStatement(
            test: id[2], consequent: id[4], alternate: consequent);
      });

  Parser forStatement() => super.forStatement().map((id) => ForStatement(
      isIndex: id[2] != null, index: id[3], list: id[5], body: id[6]));

  Parser objectProperty() => super
      .objectProperty()
      .map((id) => ObjectProperty(key: id[0], value: id[2]));
  Parser objectExpression() =>
      super.objectExpression().map((id) => ObjectExpression(properties: id[1]));

  Parser listExpression() =>
      super.listExpression().map((id) => ListExpression(elements: id[1]));
  Parser invokeFunction() => super.invokeFunction().map((id) {
        var args = id[2];
        List<ObjectProperty> arguments = [];
        for (var arg in args) {
          arguments.add(ObjectProperty(key: arg[0], value: arg[2]));
        }
        return InvokeFunction(identifier: id[0], args: arguments);
      });

  Parser statement() => super.statement().map((id) {
        print(id);
        return id;
      });

  //TODO: add data type declarations to property
  Parser listDeclaration() => super
      .listDeclaration()
      .map((id) => CallExpression(callee: Identifier(id[0].value), arguments: []..add(id[3])));

  Parser collectionDeclaration() => super
      .collectionDeclaration()
      .map((id) => CallExpression(callee: Identifier(id[0].value), arguments: []..add(id[2])));

  //Parser error() => super.error().map((id) => Error());
}

class Error {
  String error = 'error';
}
