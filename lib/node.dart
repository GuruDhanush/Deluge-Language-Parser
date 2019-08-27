import 'package:DelugeDartParser/server/language/hover.dart';
import 'package:DelugeDartParser/server/messaging/message.dart';
import 'package:petitparser/petitparser.dart';

class Node {
  int start;
  int end;

  //Loc startLoc;
  int length;
  //Loc endLoc;

  Object val;
  Map extra = Map();
  static List<Token> newLineToken = [];
  static int _line = 0;
  static int _offset = 0;


  Node({this.start, this.end, this.length});

  Node.fromId(id, {bool isBlockType = false}) {
    start = id.start;
    end = id.stop;
    length = id.length;
  }

      
  Node.fromIdWithEnd(id, {bool isBlockType = false}) {
    start = id.start;
    end = id.stop;
    length = id.length;
  }

  bool isInside(int pos) {

    if(start == null || end == null) {
       return false;
    }
    return  start <= pos && end > pos;
  } 

  @override
  String toString() {
    return '${start}:${end}';
  }
}


class Trekken {

  int start;
  int stop;
  int length;

  Trekken(this.start, this.stop, this.length);
}

class EmptySpace extends Node {
  EmptySpace({id}) : super.fromId(id);
}

class Loc {
  int line;
  int column;

  Loc({this.line, this.column});
  Loc.fromLineColumn(String buffer, int length) {
    var loc = Token.lineAndColumnOf(buffer, length);
    this.line = loc[0];
    this.column = loc[1];
  }

  Loc withCol(int _column) => Loc(line: line, column: _column);

  Loc withLine(int _line) => Loc(line: _line, column: column);

  ///Checks whether the loc obj is before the given loc obj
  bool isBefore(Loc loc) {
    return this.line <= loc.line && this.column < loc.column;
  }

  ///Checks whether the loc obj is after the given loc obj
  bool isAfter(Loc loc) {
    return this.line >= loc.line && this.column > loc.column;
  }
}

class ExpressionStatement extends Node {
  Object expression;

  ExpressionStatement({this.expression}) : super();
  ExpressionStatement.fromId({this.expression, id}) : super.fromId(id);
  ExpressionStatement.fromIdWithEnd({this.expression, id})
      : super.fromIdWithEnd(id);
}

class AssignmentExpression extends Node {
  String ooperator;
  Object left;
  Object right;

  AssignmentExpression({this.left, this.ooperator, this.right}) : super();
  AssignmentExpression.fromId({this.left, this.ooperator, this.right, id})
      : super.fromId(id);

  // Hover onHover(Loc loc) {
  //   if (left is Node && (left as Node).isInsideLine(loc)) {
  //     var hover = Hover(
  //         content: MarkupContent(
  //             kind: MarkupKind.markdown,
  //             value: "Identifier ${(left as Node).startLoc.column}"));
  //     return hover;
  //   }
  //   return null;
  // }
}

class Identifier extends Node {
  String name;
  String rawValue;

  Identifier(this.name) : super();
  Identifier.fromId({this.name, this.rawValue, id}) : super.fromId(id);

  // int isInside(Loc loc) {
  //   if (startLoc == null || length == null) return -1;
  //   if (loc.line == startLoc.line && startLoc.column + length > loc.column) {
  //     return 0;
  //   }
  //   return -1;
  // }
}

class ForStatement extends Node {
  Identifier index;
  Object list;
  bool isIndex;
  Object body;

  ForStatement({this.index, this.list, this.isIndex, this.body}) : super();
  ForStatement.fromId({this.index, this.list, this.isIndex, this.body, id})
      : super.fromId(id, isBlockType: true);
}

class CallExpression extends Node {
  Object callee;
  List<Object> arguments = [];

  CallExpression({this.callee, this.arguments}) : super();
  CallExpression.fromId({this.callee, this.arguments, id}) : super.fromId(id);
}

class BigIntLiteral extends Node {
  int value;
  String raw;

  BigIntLiteral({this.value, this.raw}) : super();
  BigIntLiteral.fromId({this.value, this.raw, id}) : super.fromId(id);
}

class BooleanLiteral extends Node {
  bool value;
  String raw;

  BooleanLiteral({this.value, this.raw}) : super();
  BooleanLiteral.fromId({this.value, this.raw, id}) : super.fromId(id);
}

class DecimalLiteral extends Node {
  double value;
  String raw;

  DecimalLiteral({this.value, this.raw}) : super();
  DecimalLiteral.fromId({this.value, this.raw, id}) : super.fromId(id);
}

class StringLiteral extends Node {
  List value;
  String raw;

  StringLiteral({this.value, this.raw}) : super();
  StringLiteral.fromId({this.value, this.raw, id}) : super.fromId(id);
}

class MemberExpression extends Node {
  Object object;
  Object propery;

  MemberExpression({this.object, this.propery}) : super();
  MemberExpression.fromId({this.object, this.propery, id}) : super.fromId(id);
}

class BinaryExpression extends Node {
  Object left;
  String oopertor;
  Object right;

  BinaryExpression({this.left, this.oopertor, this.right}) : super();
  BinaryExpression.fromId({this.left, this.oopertor, this.right, id})
      : super.fromId(id);

  //BinaryExpression.empty() : super();
}

class MapExpression extends Node {
  List<ObjectProperty> properties;
}

class ObjectProperty extends Node {
  Object key;
  Object value;

  ObjectProperty({this.key, this.value}) : super();
  ObjectProperty.fromId({this.key, this.value, id}) : super.fromId(id);
}

class LogicalExpression extends Node {
  Object left;
  String oopertor;
  Object right;

  LogicalExpression({this.left, this.oopertor, this.right}) : super();
  LogicalExpression.fromId({this.left, this.oopertor, this.right, id})
      : super.fromId(id);
}

class ReturnStatement extends Node {
  Object argument;

  ReturnStatement({this.argument}) : super();
  ReturnStatement.fromId({this.argument, id}) : super.fromId(id);
  ReturnStatement.fromIdWithEnd({this.argument, id}) : super.fromIdWithEnd(id);
}

class InfoExpression extends Node {
  Object argument;

  InfoExpression({this.argument}) : super();
  InfoExpression.fromId({this.argument, id}) : super.fromId(id);
  InfoExpression.fromIdWithEnd({this.argument, id}) : super.fromIdWithEnd(id);
}

class IfExpression extends Node {
  Object test;
  Object value;
  Object alternate;

  IfExpression({this.test, this.value, this.alternate}) : super();
  IfExpression.fromId({this.test, this.value, this.alternate, id})
      : super.fromId(id);
}

class IfNullExpression extends Node {
  Object value;
  Object alternate;

  IfNullExpression({this.value, this.alternate}) : super();
  IfNullExpression.fromId({this.value, this.alternate, id}) : super.fromId(id);
}

class IfStatement extends Node {
  Object test;
  Object consequent;
  Object alternate;

  IfStatement({this.test, this.consequent, this.alternate}) : super();
  IfStatement.fromId({this.test, this.consequent, this.alternate, id})
      : super.fromId(id, isBlockType: true);
}

class BlockStatement extends Node {
  List<Object> body;

  BlockStatement({this.body}) : super();
  BlockStatement.fromId({this.body, id}) : super.fromId(id);
  BlockStatement.fromIdWithEnd({this.body, id}) : super.fromIdWithEnd(id, isBlockType: true);

  // bool isInsideBlock(Loc loc) =>
  //     (loc.line > startLoc.line || //before line start
  //         (loc.line == startLoc.line && loc.column >= startLoc.column)) && // same line start
  //     (loc.line < endLoc.line ||  // after line end
  //         (loc.line == endLoc.line && loc.column <= endLoc.column)); // same line end
}

class UnaryExpression extends Node {
  String ooperator;
  Object expression;

  UnaryExpression({this.expression, this.ooperator}) : super();
  UnaryExpression.fromId({this.expression, this.ooperator, id})
      : super.fromId(id);
}

class ObjectExpression extends Node {
  List<Object> properties;

  ObjectExpression({this.properties}) : super();
  ObjectExpression.fromId({this.properties, id}) : super.fromId(id);
}

class ListExpression extends Node {
  List<Object> elements;

  ListExpression({this.elements}) : super();
  ListExpression.fromId({this.elements, id}) : super.fromId(id);
}

class InvokeFunction extends Node {
  Object identifier;
  List<Object> args;

  InvokeFunction({this.identifier, this.args}) : super();
  InvokeFunction.fromId({this.identifier, this.args, id}) : super.fromId(id, isBlockType: true);
}

class CommentLine extends Node {
  Object value;

  CommentLine.fromId({this.value, id}) : super.fromId(id);

  // int isInside(Loc loc) {
  //   return startLoc.line == loc.line && startLoc.column + length < loc.column
  //       ? 0
  //       : -1;
  // }
}

class LineError extends Node {
  String error;
  LineError({this.error}) : super();
  LineError.fromId({this.error, id}) : super.fromId(id);
  LineError.fromIdWithEnd({this.error, id}) : super.fromIdWithEnd(id);

}
