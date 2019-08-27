import 'dart:io';

import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/docs/docs.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/messaging/message.dart';
import 'package:DelugeDartParser/server/util.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:petitparser/petitparser.dart' as prefix0;
import 'package:tuple/tuple.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

class HoverProvider {
  static Peer _peer;

  static registerHoverProvider(Peer peer) {
    _peer = peer;
    _peer.registerMethod('textDocument/hover', onHover);
  }

  static int findPosition(Loc loc, Uri uri) {
    if (Sync.newLineTokens.containsKey(uri)) {
      if (loc.line == 0) return 0 + loc.column;
      var line = Sync.newLineTokens[uri][loc.line - 1] as prefix0.Token;
      return line.stop + loc.column;
    }
    return -1;
  }

  static MarkupContent buildMarkUp(Map identifier) {
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

  static onHover(params) async {
    var docParams = TextDocumentPositionParams.fromJson(params);

    var result = Sync.openFiles[docParams.textDocument.uri];
    var loc = Loc(
        line: docParams.position.line, column: docParams.position.character);

    var pos = findPosition(loc, docParams.textDocument.uri);

    if (pos == -1) {
      Message.sendMessageNotif(MessageType.error, 'couldnt find pos');
      return null;
    }

    var finalResult = treeTraverse(pos, result);

    if (finalResult != null && finalResult is Identifier) {
      var docs = Docs.searchDoc(finalResult.name.trim());
      if (docs == null) return null;

      return Hover(
        content: buildMarkUp(docs as Map),
      ).toJson();
    }
  }

  static treeTraverse(int position, Object exp) {
    if (exp is List) {
      for (var line in exp) {
        var result = treeTraverse(position, line);
        if (result != null) return result;
      }
    } else if (exp is BlockStatement) {
      if (!exp.isInside(position)) {
        return null;
      }
      for (var line in exp.body) {
        var result = treeTraverse(position, line);
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
      return treeTraverse(position, exp.body);
    } else if (exp is IfStatement) {
      return treeTraverse(position, exp.test) ??
          treeTraverse(position, exp.consequent) ??
          treeTraverse(position, exp.alternate);
    } else if (exp is Identifier && exp.isInside(position)) {
      return exp;
    } else if (exp is LineError) {
    } else if (exp is CommentLine && exp.isInside(position)) {
      return null;
    } else if (exp is ExpressionStatement) {
      return treeTraverse(position, (exp.expression as List)[0]);
    } else if (exp is AssignmentExpression) {
      return treeTraverse(position, exp.left) ??
          treeTraverse(position, exp.right);
    } else if (exp is CallExpression) {
      for (var arg in exp.arguments) {
        var result = treeTraverse(position, arg);
        if (result != null) return result;
      }
      return treeTraverse(position, exp.callee);
    } else if (exp is MemberExpression) {
      return treeTraverse(position, exp.object) ??
          treeTraverse(position, exp.propery);
    } else if (exp is BinaryExpression) {
      return treeTraverse(position, exp.left) ??
          treeTraverse(position, exp.right);
    } else if (exp is LogicalExpression) {
      return treeTraverse(position, exp.left) ??
          treeTraverse(position, exp.right);
    } else if (exp is ReturnStatement) {
      return treeTraverse(position, exp.argument);
    } else if (exp is MapExpression) {
      for (var prop in exp.properties) {
        var result = treeTraverse(position, prop);
        if (result != null) return result;
      }
    } else if (exp is ObjectProperty) {
      return treeTraverse(position, exp.key) ??
          treeTraverse(position, exp.value);
    } else if (exp is InfoExpression) {
      return treeTraverse(position, exp.argument);
    } else if (exp is IfExpression) {
      return treeTraverse(position, exp.test) ??
          treeTraverse(position, exp.value) ??
          treeTraverse(position, exp.alternate);
    } else if (exp is IfNullExpression) {
      return treeTraverse(position, exp.value) ??
          treeTraverse(position, exp.alternate);
    } else if (exp is UnaryExpression) {
      return treeTraverse(position, exp.expression);
    } else if (exp is ObjectExpression) {
      for (var prop in exp.properties) {
        var result = treeTraverse(position, prop);
        if (result != null) return result;
      }
    } else if (exp is ListExpression) {
      for (var prop in exp.elements) {
        var result = treeTraverse(position, prop);
        if (result != null) return result;
      }
    } else if (exp is InvokeFunction) {
      var result = treeTraverse(position, exp.identifier);
      if (result != null) return result;
      for (var prop in exp.args) {
        var result = treeTraverse(position, prop);
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

enum MarkupKind { plaintext, markdown }

class MarkupContent {
  MarkupKind kind;
  String value;

  Map toJson() => {
        'kind': MarkupKind.markdown == kind ? 'markdown' : 'plaintext',
        'value': value
      };

  MarkupContent({this.kind, this.value});
}

class Hover {
  MarkupContent content;
  Range range;
  Hover({this.content, this.range});

  Map toJson() => {
        'contents': content.toJson(),
        //'range': range.toJson()
      };
}

class TextDocumentPositionParams {
  TextDocumentIdentifier textDocument;
  Position position;
  TextDocumentPositionParams({this.textDocument, this.position});

  TextDocumentPositionParams.fromJson(params) {
    textDocument = TextDocumentIdentifier.fromJson(params['textDocument']);
    position = Position.fromJson(params['position']);
  }

  Map toJson() =>
      {'textDocument': textDocument.toJson(), 'position': position.toJson()};
}
