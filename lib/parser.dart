import 'package:DelugeDartParser/lexer.dart';
import 'package:DelugeDartParser/node.dart';
import 'package:petitparser/petitparser.dart';

DelugeParser ParserDG = DelugeParser();

class DelugeParser extends GrammarParser {
  DelugeParser() : super(DelugeParserDefinition());
}

class DelugeParserDefinition extends DgGrammarDef {
  Parser identifier() => super.identifier().map(
      (id) => Identifier.fromId(id: id, name: id.value, rawValue: id.input));

  Parser bigintLiteral() => super.bigintLiteral().map(
      (id) => BigIntLiteral.fromId(value: id.value, raw: id.input, id: id));

  Parser decimalLiteral() => super.decimalLiteral().map(
      (id) => DecimalLiteral.fromId(value: id.value, raw: id.input, id: id));

  Parser stringLiteral() => super.stringLiteral().map(
      (id) => StringLiteral.fromId(value: id.value, raw: id.input, id: id));

  Parser booleanLiteral() => super.booleanLiteral().map((id) =>
      BooleanLiteral.fromId(value: id.value == 'true', raw: id.input, id: id));

  Parser binaryExpression() => super.binaryExpression().token().map((id) {
        var _tmpList = id.value[1];

        //case where we get an binary expression and next tokens tend to be zero.
        //useful in () expressions
        if (_tmpList.length == 0) return id.value[0];

        var bin = BinaryExpression.fromId(left: id.value[0], id: id);

        for (var item in _tmpList) {
          if (item.length > 0) {
            if (bin.right != null) {
              bin = BinaryExpression.fromId(left: bin, id: id);
            }
            bin.oopertor = item[0].value;
            bin.right = item[1];
          }
        }
        return bin;
      });

  Parser logicalExpression() => super.logicalExpression().token().map((id) {
        var _tmpList = id.value[1];

        //case where we get an logical expression and next tokens tend to be zero.
        //useful in () expressions
        if (_tmpList.length == 0) return id.value[0];

        var bin = LogicalExpression.fromId(left: id.value[0], id: id);

        for (var item in _tmpList) {
          if (item.length > 0) {
            if (bin.right != null) {
              bin = LogicalExpression.fromId(left: bin, id: id);
            }
            bin.oopertor = item[0].value;
            bin.right = item[1];
          }
        }
        return bin;
      });

  Parser bracketExpression() => super
      .bracketExpression()
      .token()
      .map((id) => id.value[1]..extra.putIfAbsent('parentise', () => true));

  Parser callExpression() => super.callExpression().token().map((id) {
        var args = id.value[1][1];
        var params = [];
        for (var arg in args) {
          params.add(arg);
        }
        Object exp = CallExpression.fromId(
            callee: id.value[0], arguments: params, id: id);
        for (var item in id.value[2]) {
          exp = MemberExpression.fromId(object: exp, propery: item[1], id: id);

          //dealing with call expression
          if (item[2] != null) {
            exp = CallExpression.fromId(
                callee: exp, arguments: item[2][1], id: id);
          }
        }
        return exp;
      });

  Parser memberExpression() => super.memberExpression().token().map((id) {
        Object exp = MemberExpression.fromId(
            object: id.value[0], propery: id.value[2], id: id);
        for (var item in id.value[3]) {
          exp = MemberExpression.fromId(object: exp, propery: item[1], id: id);
          if (item[2] != null) {
            exp = CallExpression.fromId(
                callee: exp, arguments: item[2][1], id: id);
          }
        }
        return exp;
      });

  Parser expressionStatement() => super.expressionStatement().token().map((id) {
        return ExpressionStatement.fromId(expression: id.value, id: id);
      });
  
  Parser singleLineComment() => super.singleLineComment().map((id) => CommentLine.fromId(value: id.value[2], id: id));
  Parser multiLineComment() => super.multiLineComment().map((id) => CommentLine.fromId(value: id.value[2], id: id));


  Parser returnStatement() => super
      .returnStatement()
      .token()
      .map((id) => ReturnStatement.fromId(argument: id.value[1], id: id));

  Parser infoExpression() => super
      .infoExpression()
      .token()
      .map((id) => InfoExpression.fromId(argument: id.value[1], id: id));

  Parser assignmentExpression() => super.assignmentExpression().token().map(
      (id) => AssignmentExpression.fromId(
          left: id.value[0],
          ooperator: id.value[1].value,
          right: id.value[2],
          id: id));

  Parser unaryExpression() =>
      super.unaryExpression().token().map((id) => UnaryExpression.fromId(
          expression: id.value[1], ooperator: id.value[0].value, id: id));

  Parser ifExpression() =>
      super.ifExpression().token().map((id) => IfExpression.fromId(
          test: id.value[2],
          value: id.value[4],
          alternate: id.value[6],
          id: id,));

  Parser ifNullExpression() =>
      super.ifNullExpression().token().map((id) => IfNullExpression.fromId(
          value: id.value[2], alternate: id.value[4], id: id));

  Parser blockStatement() => super
      .blockStatement()
      .token()
      .map((id) => BlockStatement.fromIdWithEnd(body: id.value[1], id: id));

  Parser ifStatement() => super.ifStatement().token().map((id) {
        var consequent = id.value[6] != null ? id.value[6][1] : null;
        var turns = id.value[5];
        for (var i = 0; i < turns.length; i++) {
          var item = turns[i];
          consequent = IfStatement.fromId(
              test: item[3],
              consequent: item[5],
              alternate: consequent,
              id: id);
        }
        return IfStatement.fromId(
            test: id.value[2],
            consequent: id.value[4],
            alternate: consequent,
            id: id);
      });

  Parser forStatement() =>
      super.forStatement().token().map((id) => ForStatement.fromId(
          isIndex: id.value[2] != null,
          index: id.value[3],
          list: id.value[5],
          body: id.value[6],
          id: id));

  Parser objectProperty() => super.objectProperty().token().map((id) =>
      ObjectProperty.fromId(key: id.value[0], value: id.value[2], id: id));
  Parser objectExpression() => super
      .objectExpression()
      .token()
      .map((id) => ObjectExpression.fromId(properties: id.value[1], id: id));

  Parser listExpression() => super
      .listExpression()
      .token()
      .map((id) => ListExpression.fromId(elements: id.value[1], id: id));
  Parser invokeFunction() => super.invokeFunction().token().map((id) {
        var args = id.value[2];
        List<ObjectProperty> arguments = [];
        for (var arg in args) {
          arguments
              .add(ObjectProperty.fromId(key: arg[0], value: arg[2], id: id));
        }
        return InvokeFunction.fromId(
            identifier: id.value[0], args: arguments, id: id);
      });

  Parser lineError() => super
      .lineError()
      .token()
      .map((id) => 
      LineError.fromIdWithEnd(error: 'Line error', id: id));
  
  //Parser whitespaceLine() => super.whitespaceLine().token().trim().map((id) => id);
  //.map((id) => EmptySpace(id: id));

  // Parser statement() => super.statement().map((id) {
  //       //if(id is! EmptySpace) retur;
  //       return id;
  //     });

  //TODO: add data type declarations to property
  Parser listDeclaration() =>
      super.listDeclaration().token().map((id) => CallExpression.fromId(
          callee: Identifier(id.value[0].value),
          arguments: []..add(id.value[3]),
          id: id));

  Parser collectionDeclaration() =>
      super.collectionDeclaration().token().map((id) => CallExpression.fromId(
          callee: Identifier(id.value[0].value),
          arguments: []..add(id.value[2]),
          id: id));

  //Parser error() => super.error().map((id) => Error());
}
