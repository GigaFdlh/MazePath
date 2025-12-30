import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/enums/node_type.dart';
import '../../logic/models/grid_node.dart';

class NodeWidget extends StatelessWidget {
  final GridNode node;

  const NodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.all(0.5),

      alignment: Alignment.center,

      decoration: BoxDecoration(
        color: _getColor(node.type),
        borderRadius: BorderRadius.circular(2),
        boxShadow: _getShadow(node.type),
      ),

      child: _buildIcon(node.type),
    );
  }

  Color _getColor(NodeType type) {
    switch (type) {
      case NodeType.wall:
        return AppColors.wall;
      case NodeType.start:
        return AppColors.start;
      case NodeType.end:
        return AppColors.end;
      case NodeType.visited:
        return AppColors.visited;
      case NodeType.path:
        return AppColors.path;
      case NodeType.weight:
        return AppColors.weight;
      default:
        return AppColors.gridBackground;
    }
  }

  Widget? _buildIcon(NodeType type) {
    if (type == NodeType.weight) {
      return const Icon(Icons.terrain, size: 14, color: Colors.white38);
    }
    return null;
  }

  List<BoxShadow> _getShadow(NodeType type) {
    if (type == NodeType.start ||
        type == NodeType.end ||
        type == NodeType.path) {
      return [
        BoxShadow(
          color: _getColor(type).withValues(alpha: 0.6),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    return [];
  }
}
