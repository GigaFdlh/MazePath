import '../models/grid_node.dart';
import 'dart:math';

class AStar {
  static double getHeuristic(GridNode nodeA, GridNode nodeB) {
    return sqrt(pow(nodeA.row - nodeB.row, 2) + pow(nodeA.col - nodeB.col, 2));
  }

  static List<GridNode> getNeighbors(
    GridNode node,
    List<List<GridNode>> grid,
    int rows,
    int cols, {
    bool allowDiagonal = false,
  }) {
    List<GridNode> neighbors = [];

    List<List<int>> directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];

    if (allowDiagonal) {
      directions.addAll([
        [-1, -1],
        [-1, 1],
        [1, -1],
        [1, 1],
      ]);
    }

    for (var dir in directions) {
      int newRow = node.row + dir[0];
      int newCol = node.col + dir[1];

      if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols) {
        neighbors.add(grid[newRow][newCol]);
      }
    }

    return neighbors;
  }
}
