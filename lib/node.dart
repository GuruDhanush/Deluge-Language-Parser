
class Node {

   int start;
   int end;

   Loc startLoc;
   Loc endLoc;

   Object val;
   Map extra = Map();

   Node.fromValue({this.val});

  Node({this.start, this.end, this.startLoc, this.endLoc});
}

class Loc {
   int line;
   int column;

  Loc({this.line, this.column});
}

class ExpressionStatement extends Node {

  Object expression;

  ExpressionStatement({this.expression}) : super();
}

class AssignmentExpression extends Node {

  String ooperator;
  Object left;
  Object right;

  AssignmentExpression({this.left, this.ooperator, this.right}) : super();  
}

class Identifier extends Node {
  String name;
  String rawValue;

  Identifier(this.name) : super();
}

class ForStatement extends Node {
  Object index;
  Object list;
  bool isIndex;
  Object body;
  
  ForStatement({this.index, this.list, this.isIndex, this.body}) : super();
}

class CallExpression extends Node {
  Object callee;
  List<Object> arguments = [];

  CallExpression({this.callee, this.arguments});
}

class BigIntLiteral extends Node {
  int value;
  String raw;

  BigIntLiteral({this.value, this.raw}) : super();
}

class BooleanLiteral extends Node {
  bool value;
  String raw;

  BooleanLiteral({this.value, this.raw}) : super();
}

class DecimalLiteral extends Node {
  double value;
  String raw;

  DecimalLiteral({this.value, this.raw}) : super();
}

class StringLiteral extends Node {
  List value;
  String raw;

  StringLiteral({this.value, this.raw}) : super();
}

class MemberExpression extends Node {

  Object object;
  Object propery;

  MemberExpression({this.object, this.propery}) : super();
}


class BinaryExpression extends Node {

  Object left;
  String oopertor;
  Object right;

  BinaryExpression({this.left, this.oopertor, this.right}) : super();
  //BinaryExpression.empty() : super();
}

class MapExpression extends Node {

  List<ObjectProperty> properties;
}

class ObjectProperty extends Node {
  Object key;
  Object value;

  ObjectProperty({this.key, this.value}) : super();
}

class LogicalExpression extends Node {
  Object left;
  String oopertor;
  Object right;

  LogicalExpression({this.left, this.oopertor, this.right}) : super();
  
}

class ReturnStatement extends Node {
  Object argument;

  ReturnStatement({this.argument}) : super();
}

class InfoExpression extends Node {
  Object argument;

  InfoExpression({this.argument}) : super();
}

class IfExpression extends Node {

  Object test;
  Object value;
  Object alternate;

  IfExpression({this.test, this.value, this.alternate}) : super();
}

class IfNullExpression extends Node {

  Object value;
  Object alternate;

  IfNullExpression({this.value, this.alternate}) : super();
}


class IfStatement extends Node {
  Object test;
  Object consequent;
  Object alternate;

  IfStatement({this.test, this.consequent, this.alternate});
}

class BlockStatement extends Node {
  List<Object> body;

  BlockStatement({this.body}) : super();
}

class UnaryExpression extends Node {
  String ooperator;
  Object expression;

  UnaryExpression({this.expression, this.ooperator}) : super();
}

class ObjectExpression extends Node {
  List<Object> properties;

  ObjectExpression({this.properties}) : super();
}

class ListExpression extends Node {
  List<Object> elements;

  ListExpression({this.elements}) : super();
}
