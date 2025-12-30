import '../models/grid_node.dart';

class Dijkstra {
  static List<GridNode> getNeighbors(GridNode node, List<List<GridNode>> grid, int rows, int cols) {
    List<GridNode> neighbors = [];
    List<List<int>> directions = [
      [-1, 0], 
      [1, 0], 
      [0, -1], 
      [0, 1]
    ];

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