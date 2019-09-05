import 'dart:io';

import 'package:DelugeDartParser/lsp/language/hover.dart';
import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/lsp/docs/docs.dart';
import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:DelugeDartParser/lsp/messaging/message.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:petitparser/petitparser.dart';
import 'package:tuple/tuple.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

class HoverServer {
  
  static int findPosition(Loc loc, List newLineTokens) {
    try {
      if (loc.line == 0) return 0 + loc.column;
      var line = newLineTokens[loc.line - 1] as Token;
      return line.stop + loc.column;
    } catch (e) {
      throw PositionNotFoundException('on hover: word was not found!');
    }
  }

  static MarkupContent _buildMarkUp(Map identifier) {
    var codeBlock = (code) => '```dg\n${code}\n```\n';
    var signature = (List params, String returnType, String name) {
      if (name == null) return '';
      String paramString = '   ';
      params.forEach((param) {
        var m = param as Map;
        paramString += '${m.values.first} ${m.keys.first}, ';
      });
      paramString = paramString.substring(0, paramString.length - 2).trim();
      var totalString = '$returnType $name($paramString)';
      return '${codeBlock(totalString)}- - -\n';
    };

    return MarkupContent(
        kind: MarkupKind.markdown,
        value:
            '${signature(identifier['params'], identifier['returns'], identifier['name'])} ${identifier['shortInfo']}');
  }

  static onHover(int position, List statements)  {
    var finalResult = _treeTraverse(position, statements);

    if (finalResult != null && finalResult is Identifier) {
      var docs = Docs.searchDoc(finalResult.name.trim());
      if (docs == null) return null;

      return Hover(
        content: _buildMarkUp(docs as Map),
      );
    }
  }

  static _treeTraverse(int position, Object exp) {
    if (exp is List) {
      for (var line in exp) {
        var result = _treeTraverse(position, line);
        if (result != null) return result;
      }
    } else if (exp is BlockStatement) {
      if (!exp.isInside(position)) {
        return null;
      }
      for (var line in exp.body) {
        var result = _treeTraverse(position, line);
        if (result != null) return result;
      }
    } else if (exp is ForStatement) {
      if (exp.index.isInside(position)) {
        return exp.index;
      }
      if (exp.list is Identifier &&
          (exp.list as Identifier).isInside(position)) {
        return exp.list;
      }
      return _treeTraverse(position, exp.body);
    } else if (exp is IfStatement) {
      return _treeTraverse(position, exp.test) ??
          _treeTraverse(position, exp.consequent) ??
          _treeTraverse(position, exp.alternate);
    } else if (exp is Identifier && exp.isInside(position)) {
      return exp;
    } else if (exp is LineError) {
    } else if (exp is CommentLine && exp.isInside(position)) {
      return null;
    } else if (exp is ExpressionStatement) {
      return _treeTraverse(position, (exp.expression as List)[0]);
    } else if (exp is AssignmentExpression) {
      return _treeTraverse(position, exp.left) ??
          _treeTraverse(position, exp.right);
    } else if (exp is CallExpression) {
      for (var arg in exp.arguments) {
        var result = _treeTraverse(position, arg);
        if (result != null) return result;
      }
      return _treeTraverse(position, exp.callee);
    } else if (exp is MemberExpression) {
      return _treeTraverse(position, exp.object) ??
          _treeTraverse(position, exp.propery);
    } else if (exp is BinaryExpression) {
      return _treeTraverse(position, exp.left) ??
          _treeTraverse(position, exp.right);
    } else if (exp is LogicalExpression) {
      return _treeTraverse(position, exp.left) ??
          _treeTraverse(position, exp.right);
    } else if (exp is ReturnStatement) {
      return _treeTraverse(position, exp.argument);
    } else if (exp is MapExpression) {
      for (var prop in exp.properties) {
        var result = _treeTraverse(position, prop);
        if (result != null) return result;
      }
    } else if (exp is ObjectProperty) {
      return _treeTraverse(position, exp.key) ??
          _treeTraverse(position, exp.value);
    } else if (exp is InfoExpression) {
      return _treeTraverse(position, exp.argument);
    } else if (exp is IfExpression) {
      return _treeTraverse(position, exp.test) ??
          _treeTraverse(position, exp.value) ??
          _treeTraverse(position, exp.alternate);
    } else if (exp is IfNullExpression) {
      return _treeTraverse(position, exp.value) ??
          _treeTraverse(position, exp.alternate);
    } else if (exp is UnaryExpression) {
      return _treeTraverse(position, exp.expression);
    } else if (exp is ObjectExpression) {
      for (var prop in exp.properties) {
        var result = _treeTraverse(position, prop);
        if (result != null) return result;
      }
    } else if (exp is ListExpression) {
      for (var prop in exp.elements) {
        var result = _treeTraverse(position, prop);
        if (result != null) return result;
      }
    } else if (exp is InvokeFunction) {
      var result = _treeTraverse(position, exp.identifier);
      if (result != null) return result;
      for (var prop in exp.args) {
        var result = _treeTraverse(position, prop);
        if (result != null) return result;
      }
    } else if (exp is BooleanLiteral ||
        exp is BigIntLiteral ||
        exp is DecimalLiteral ||
        exp is StringLiteral) {
      return null;
    }
  }
}

class PositionNotFoundException implements Exception {
  final String message;

  const PositionNotFoundException([this.message = '']);

  String toString() => "Position not found. $message";
}
