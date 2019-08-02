import 'package:DelugeDartParser/parser.dart';
import 'package:petitparser/petitparser.dart';
import 'package:graphs/graphs.dart' as gp;
import 'package:DelugeDartParser/node.dart';

main(List<String> arguments) {
  // var nodeA = Node('A', 1);
  // var nodeB = Node('B', 2);
  // var nodeC = Node('C', 3);
  // var nodeD = Node('D', 4);
  // var graph = Graph({
  //   nodeA: [nodeB, nodeC],
  //   nodeB: [nodeC, nodeD],
  //   nodeC: [nodeB, nodeD]
  // });

  // var components = gp.stronglyConnectedComponents<Node>(
  //     graph.nodes.keys, (node) => graph.nodes[node]);

  // print(components);

  Node n = Node(start: 10, end: 11);
  print("${n.start}, ${n.end}");
  


}

// class Graph {
//   final Map<Node, List<Node>> nodes;

//   Graph(this.nodes);
// }

// class Node {
//   final String id;
//   final int data;

//   Node(this.id, this.data);

//   @override
//   bool operator ==(Object other) => other is Node && other.id == id;

//   @override
//   int get hashCode => id.hashCode;

//   @override
//   String toString() => '<$id -> $data>';
// }
