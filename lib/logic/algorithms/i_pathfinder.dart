import '../models/grid_node.dart';

abstract class IPathfinder {
  List<GridNode> reconstructPath(GridNode endNode);
}