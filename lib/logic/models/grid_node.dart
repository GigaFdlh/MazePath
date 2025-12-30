import '../../core/enums/node_type.dart';

class GridNode {
  final int row;
  final int col;
  NodeType type;

  GridNode? parent;

  double gCost;
  double hCost;

  GridNode({
    required this.row,
    required this.col,
    this.type = NodeType.empty,
    this.gCost = 0,
    this.hCost = 0,
  });

  double get fCost => gCost + hCost;

  void reset() {
    if (type == NodeType.visited || type == NodeType.path) {
      type = NodeType.empty;
    }

    parent = null;
    gCost = 0;
    hCost = 0;
  }

  void hardReset() {
    type = NodeType.empty;
    parent = null;
    gCost = 0;
    hCost = 0;
  }

  @override
  String toString() => 'Node($row, $col, $type)';
}
