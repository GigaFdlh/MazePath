import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visualizer_provider.dart';
import 'node_widget.dart';

class GridBoard extends StatelessWidget {
  const GridBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VisualizerProvider>(
      builder: (context, provider, child) {
        return AspectRatio(
          aspectRatio: 1.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double boardWidth = constraints.maxWidth;
              final double nodeSize = boardWidth / provider.cols;

              return GestureDetector(
                onPanStart: (details) {
                  final dx = details.localPosition.dx;
                  final dy = details.localPosition.dy;

                  int col = (dx / nodeSize).floor();
                  int row = (dy / nodeSize).floor();

                  provider.onDragStart(row, col);
                },

                onPanUpdate: (details) {
                  final dx = details.localPosition.dx;
                  final dy = details.localPosition.dy;

                  int col = (dx / nodeSize).floor();
                  int row = (dy / nodeSize).floor();

                  provider.onDragUpdate(row, col);
                },

                onTapUp: (details) {
                  final dx = details.localPosition.dx;
                  final dy = details.localPosition.dy;

                  int col = (dx / nodeSize).floor();
                  int row = (dy / nodeSize).floor();

                  provider.handleTouch(row, col);
                },

                child: Container(
                  padding: const EdgeInsets.all(0.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.rows * provider.cols,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: provider.cols,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final int row = index ~/ provider.cols;
                      final int col = index % provider.cols;
                      final node = provider.grid[row][col];

                      return IgnorePointer(child: NodeWidget(node: node));
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
