
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

  Node expression;

}

class AssignmentExpression extends Node {

  String opeator;
  Node left;
  Node Right;  
}

class Identifier extends Node {
  String name;
  String rawValue;

  Identifier(this.name) : super();
}

class ForStatement extends Node {
  Node init;
  Node body;
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

class BlockStatement extends Node {
  List<Node> body;
}

class MemberExpression extends Node {

  Object object;
  Object propery;

  MemberExpression({this.object, this.propery}) : super();
}

class IfStatement extends Node {
  Node test;
  Node consequent;
  Node alternate;
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
  Node key;
  Node value;
}

class LogicalExpression extends Node {
  Node left;
  Node ooperator;
  Node right;
}

class ReturnStatement extends Node {
  Node argument;
}



