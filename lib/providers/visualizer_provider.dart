import 'dart:async'; 
import 'dart:math'; 
import 'dart:collection'; // PENTING: Untuk Queue (BFS)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/enums/node_type.dart';
import '../core/enums/algorithm_type.dart'; 
import '../logic/algorithms/a_star.dart';
import '../logic/models/grid_node.dart';

class VisualizerProvider extends ChangeNotifier {
  // --- 1. CONFIG ---
  final int rows = 15; 
  final int cols = 15; 
  List<List<GridNode>> grid = [];
  late GridNode startNode;
  late GridNode endNode;
  bool isRunning = false; 
  AlgorithmType selectedAlgorithm = AlgorithmType.aStar;
  int wallBrushSize = 1;
  bool isWeightBrush = false; 
  bool allowDiagonal = false; 
  bool _isDrawing = true; 
  bool _isDraggingStart = false;
  bool _isDraggingEnd = false;
  int executionTime = 0;
  int visitedCount = 0;
  int pathLength = 0;

  VisualizerProvider() {
    createGrid();
  }

  void setAlgorithm(AlgorithmType type) {
    selectedAlgorithm = type;
    notifyListeners();
  }

  void setBrushSize(double value) {
    wallBrushSize = value.toInt();
    notifyListeners();
  }

  void toggleBrushType(bool isWeight) {
    isWeightBrush = isWeight;
    notifyListeners();
  }

  void toggleDiagonal(bool value) {
    allowDiagonal = value;
    notifyListeners();
  }

  void createGrid() {
    isRunning = false; 
    _resetStats();
    grid = []; 
    for (int i = 0; i < rows; i++) {
      List<GridNode> rowList = [];
      for (int j = 0; j < cols; j++) {
        rowList.add(GridNode(row: i, col: j, type: NodeType.empty));
      }
      grid.add(rowList);
    }
    startNode = grid[0][0];
    startNode.type = NodeType.start;
    endNode = grid[rows - 1][cols - 1];
    endNode.type = NodeType.end;
    notifyListeners();
  }

  // --- DRAG LOGIC ---
  void onDragStart(int row, int col) {
    if (isRunning) return;
    if (!_isValidIndex(row, col)) return;

    final node = grid[row][col];
    _isDraggingStart = false;
    _isDraggingEnd = false;

    if (node.type == NodeType.start) {
      _isDraggingStart = true;
    } else if (node.type == NodeType.end) {
      _isDraggingEnd = true;
    } else {
      NodeType currentBrushType = isWeightBrush ? NodeType.weight : NodeType.wall;
      if (node.type == currentBrushType) {
        _isDrawing = false; 
      } else {
        _isDrawing = true;  
      }
      _updateNodeFromBrush(row, col);
    }
  }

  void onDragUpdate(int row, int col) {
    if (isRunning) return;
    if (!_isValidIndex(row, col)) return;
    if (pathLength > 0 || visitedCount > 0) clearPath(); 

    if (_isDraggingStart) {
      _moveStartNode(row, col);
    } else if (_isDraggingEnd) {
      _moveEndNode(row, col);
    } else {
      _updateNodeFromBrush(row, col);
    }
  }

  void _moveStartNode(int row, int col) {
    final target = grid[row][col];
    if (target.type != NodeType.end && target.type != NodeType.wall) {
      if (startNode != target) {
        startNode.type = NodeType.empty; 
        startNode = target;
        startNode.type = NodeType.start;
        notifyListeners();
      }
    }
  }

  void _moveEndNode(int row, int col) {
    final target = grid[row][col];
    if (target.type != NodeType.start && target.type != NodeType.wall) {
      if (endNode != target) {
        endNode.type = NodeType.empty; 
        endNode = target;
        endNode.type = NodeType.end; 
        notifyListeners();
      }
    }
  }

  void _updateNodeFromBrush(int row, int col) {
    for (int i = 0; i < wallBrushSize; i++) {
      for (int j = 0; j < wallBrushSize; j++) {
        int targetRow = row + i;
        int targetCol = col + j;

        if (_isValidIndex(targetRow, targetCol)) {
          final node = grid[targetRow][targetCol];
          if (node.type == NodeType.start || node.type == NodeType.end) continue;

          NodeType brushType = isWeightBrush ? NodeType.weight : NodeType.wall;
          NodeType targetType = _isDrawing ? brushType : NodeType.empty;

          if (node.type != targetType) {
            node.type = targetType;
            if (_isDrawing) HapticFeedback.selectionClick(); 
          }
        }
      }
    }
    notifyListeners();
  }

  void handleTouch(int row, int col) {
    if (isRunning) return; 
    if (!_isValidIndex(row, col)) return;
    onDragStart(row, col);
  }

  // --- MASTER RUN ALGORITHM ---
  Future<void> runAlgorithm() async {
    clearPath(); 
    Stopwatch stopwatch = Stopwatch()..start();
    _resetStats();
    isRunning = true;
    notifyListeners();

    // PILIH ALGORITMA SESUAI ENUM
    if (selectedAlgorithm == AlgorithmType.bfs) {
      await _runBFS();
    } else if (selectedAlgorithm == AlgorithmType.dfs) {
      await _runDFS();
    } else {
      await _runWeightedSearch();
    }
  
    stopwatch.stop();
    if (executionTime == 0) executionTime = stopwatch.elapsedMilliseconds;
    
    isRunning = false;
    notifyListeners();
  }

  // --- 1. A* & DIJKSTRA
  Future<void> _runWeightedSearch() async {
    List<GridNode> openSet = [];  
    List<GridNode> closedSet = []; 

    openSet.add(startNode);
    
    while (openSet.isNotEmpty) {
      if (!isRunning) break; 

      openSet.sort((a, b) => a.fCost.compareTo(b.fCost));
      GridNode currentNode = openSet.removeAt(0);
      closedSet.add(currentNode);

      if (currentNode != startNode && currentNode != endNode) {
        visitedCount++; 
        if (currentNode.type != NodeType.weight) {
          currentNode.type = NodeType.visited;
        }
        notifyListeners(); 
        await Future.delayed(const Duration(milliseconds: 10)); 
      }

      if (currentNode == endNode) {
        await _reconstructPath(currentNode); 
        return;
      }

      List<GridNode> neighbors = AStar.getNeighbors(currentNode, grid, rows, cols, allowDiagonal: allowDiagonal);
      
      for (var neighbor in neighbors) {
        if (neighbor.type == NodeType.wall || closedSet.contains(neighbor)) continue;
        double moveCost = 1.0;
        bool isDiagonal = (neighbor.row != currentNode.row) && (neighbor.col != currentNode.col);
        if (isDiagonal) moveCost = 1.4;
        if (neighbor.type == NodeType.weight) moveCost += 5;
        
        double newMovementCostToNeighbor = currentNode.gCost + moveCost;
        bool isInOpenSet = openSet.contains(neighbor);

        if (newMovementCostToNeighbor < neighbor.gCost || !isInOpenSet) {
          neighbor.gCost = newMovementCostToNeighbor;
          
          if (selectedAlgorithm == AlgorithmType.aStar) {
            neighbor.hCost = AStar.getHeuristic(neighbor, endNode);
          } else {
            neighbor.hCost = 0; // Dijkstra
          }
          
          neighbor.parent = currentNode; 
          if (!isInOpenSet) openSet.add(neighbor);
        }
      }
    }
  }

  // --- 2. BFS (Unweighted - Queue) ---
  Future<void> _runBFS() async {
    Queue<GridNode> queue = Queue();
    Set<GridNode> visited = {};

    queue.add(startNode);
    visited.add(startNode);

    while (queue.isNotEmpty) {
      if (!isRunning) break;

      GridNode currentNode = queue.removeFirst();

      if (currentNode == endNode) {
        await _reconstructPath(currentNode);
        return;
      }

      if (currentNode != startNode) {
        visitedCount++;
        if (currentNode.type != NodeType.weight) {
           currentNode.type = NodeType.visited;
        }
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // BFS juga menghormati setting Diagonal
      List<GridNode> neighbors = AStar.getNeighbors(currentNode, grid, rows, cols, allowDiagonal: allowDiagonal);
      for (var neighbor in neighbors) {
        if (neighbor.type != NodeType.wall && !visited.contains(neighbor)) {
          visited.add(neighbor);
          neighbor.parent = currentNode;
          queue.add(neighbor);
        }
      }
    }
  }

  // --- 3. DFS (Unweighted - Stack) ---
  Future<void> _runDFS() async {
    List<GridNode> stack = [];
    Set<GridNode> visited = {};

    stack.add(startNode);

    while (stack.isNotEmpty) {
      if (!isRunning) break;

      GridNode currentNode = stack.removeLast(); // LIFO

      if (currentNode == endNode) {
        await _reconstructPath(currentNode);
        return;
      }

      if (!visited.contains(currentNode)) {
        visited.add(currentNode);
        
        if (currentNode != startNode) {
          visitedCount++;
          if (currentNode.type != NodeType.weight) {
             currentNode.type = NodeType.visited;
          }
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 10));
        }

        List<GridNode> neighbors = AStar.getNeighbors(currentNode, grid, rows, cols, allowDiagonal: allowDiagonal);
        for (var neighbor in neighbors) {
          if (neighbor.type != NodeType.wall && !visited.contains(neighbor)) {
            neighbor.parent = currentNode;
            stack.add(neighbor);
          }
        }
      }
    }
  }

  // --- HELPERS ---
  Future<void> _reconstructPath(GridNode current) async {
    GridNode? temp = current;
    while (temp != null) {
      pathLength++; 
      if (temp != startNode && temp != endNode) {
        temp.type = NodeType.path; 
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 20)); 
      }
      temp = temp.parent; 
    }
    if (pathLength > 0) pathLength--;
  }

  void _resetStats() {
    executionTime = 0;
    visitedCount = 0;
    pathLength = 0;
  }

  void clearPath() {
    _resetStats();
    for (var rowList in grid) {
      for (var node in rowList) {
        if (node.type != NodeType.wall && 
            node.type != NodeType.start && 
            node.type != NodeType.end &&
            node.type != NodeType.weight) {
          node.type = NodeType.empty;
        }
        node.reset(); 
      }
    }
    notifyListeners();
  }

  void resetGrid() {
    createGrid(); 
  }
  
  void generateRandomMaze() {
    createGrid(); 
    final random = Random();
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final node = grid[i][j];
        if (node.type == NodeType.start || node.type == NodeType.end) continue;
        
        double chance = random.nextDouble();
        if (chance < 0.25) {
          node.type = NodeType.wall;
        } else if (chance > 0.25 && chance < 0.35) {
          node.type = NodeType.weight;
        }
      }
    }
    notifyListeners();
  }

  Future<void> generateRecursiveMaze() async {
    createGrid();
    for (int i = 0; i < rows; i++) {
      grid[i][0].type = NodeType.wall;
      grid[i][cols - 1].type = NodeType.wall;
    }
    for (int j = 0; j < cols; j++) {
      grid[0][j].type = NodeType.wall;
      grid[rows - 1][j].type = NodeType.wall;
    }
    notifyListeners();

    await _divide(1, rows - 2, 1, cols - 2, _chooseOrientation(rows, cols));
    
    startNode.type = NodeType.start;
    endNode.type = NodeType.end;
    
    if (rows > 2 && cols > 2) {
      grid[0][1].type = NodeType.empty; 
      grid[1][0].type = NodeType.empty;
      grid[1][1].type = NodeType.empty;
      grid[rows-2][cols-1].type = NodeType.empty;
      grid[rows-1][cols-2].type = NodeType.empty;
      grid[rows-2][cols-2].type = NodeType.empty;
    }
    notifyListeners();
  }

  int _chooseOrientation(int width, int height) {
    if (width < height) return 0; 
    if (height < width) return 1; 
    return Random().nextInt(2);
  }

  Future<void> _divide(int r1, int r2, int c1, int c2, int orientation) async {
    if (r2 < r1 || c2 < c1) return; 

    bool isHorizontal = orientation == 0;
    
    int wallX = isHorizontal 
        ? r1 + Random().nextInt(max(1, (r2 - r1 + 1))) 
        : c1 + Random().nextInt(max(1, (c2 - c1 + 1)));

    int passage = isHorizontal 
        ? c1 + Random().nextInt(max(1, (c2 - c1 + 1))) 
        : r1 + Random().nextInt(max(1, (r2 - r1 + 1)));

    if (isHorizontal) {
      for (int c = c1; c <= c2; c++) {
        if (c != passage && grid[wallX][c].type != NodeType.start && grid[wallX][c].type != NodeType.end) {
          grid[wallX][c].type = NodeType.wall;
        }
      }
    } else {
      for (int r = r1; r <= r2; r++) {
        if (r != passage && grid[r][wallX].type != NodeType.start && grid[r][wallX].type != NodeType.end) {
          grid[r][wallX].type = NodeType.wall;
        }
      }
    }
    
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 20));

    int nx = wallX;
    int ny = wallX;

    if (isHorizontal) {
      if (nx - 2 - r1 > 0) await _divide(r1, nx - 1, c1, c2, _chooseOrientation(nx - 1 - r1, c2 - c1));
      if (r2 - (ny + 1) > 0) await _divide(ny + 1, r2, c1, c2, _chooseOrientation(r2 - (ny + 1), c2 - c1));
    } else {
      if (nx - 2 - c1 > 0) await _divide(r1, r2, c1, nx - 1, _chooseOrientation(r2 - r1, nx - 1 - c1));
      if (c2 - (ny + 1) > 0) await _divide(r1, r2, ny + 1, c2, _chooseOrientation(r2 - r1, c2 - (ny + 1)));
    }
  }

  bool _isValidIndex(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }
}