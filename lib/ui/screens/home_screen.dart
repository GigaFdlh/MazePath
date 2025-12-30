import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/algorithm_type.dart';
import '../../providers/visualizer_provider.dart';
import '../widgets/grid_board.dart';
import '../widgets/result_dialog.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VisualizerProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Press back again to exit"),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.grey[800],
            ),
          );
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.route, color: AppColors.start),
              const SizedBox(width: 10),
              const Text(
                "MazePath",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridBoard(),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.gridBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AlgorithmType>(
                        value: provider.selectedAlgorithm,
                        dropdownColor: AppColors.gridBackground,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.start,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: AlgorithmType.aStar,
                            child: Text("🚀  A* (A-Star) - Smart"),
                          ),
                          DropdownMenuItem(
                            value: AlgorithmType.dijkstra,
                            child: Text("🛡️  Dijkstra - Thorough"),
                          ),
                          DropdownMenuItem(
                            value: AlgorithmType.bfs,
                            child: Text("🌊  BFS - Unweighted"),
                          ),
                          DropdownMenuItem(
                            value: AlgorithmType.dfs,
                            child: Text("🌀  DFS - Deep Explorer"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) provider.setAlgorithm(val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        Icons.timer,
                        "${provider.executionTime} ms",
                        "Time",
                      ),
                      _buildContainerDivider(),
                      _buildStatItem(
                        Icons.visibility,
                        "${provider.visitedCount}",
                        "Visited",
                      ),
                      _buildContainerDivider(),
                      _buildStatItem(
                        Icons.timeline,
                        "${provider.pathLength}",
                        "Steps",
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white10, height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _buildBrushSelector(
                          context,
                          provider,
                          label: "Wall",
                          isWeight: false,
                          isActive: !provider.isWeightBrush,
                          color: AppColors.wall,
                          icon: Icons.square,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildBrushSelector(
                          context,
                          provider,
                          label: "Mud",
                          isWeight: true,
                          isActive: provider.isWeightBrush,
                          color: AppColors.weight,
                          icon: Icons.terrain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PopupMenuButton<int>(
                        color: AppColors.gridBackground,
                        offset: const Offset(0, -110),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 1,
                            child: Text(
                              "Simple Noise",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 2,
                            child: Text(
                              "Recursive Maze",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                        onSelected: (val) => val == 1
                            ? provider.generateRandomMaze()
                            : provider.generateRecursiveMaze(),
                        child: _buildCircleBtnContent(
                          icon: Icons.add_location_alt_outlined,
                          color: Colors.orange,
                          label: "Generate",
                        ),
                      ),
                      _buildCircleBtn(
                        icon: Icons.cleaning_services_outlined,
                        color: Colors.blueAccent,
                        label: "Clear Path",
                        onTap: () => provider.clearPath(),
                      ),
                      _buildCircleBtn(
                        icon: Icons.delete_outline,
                        color: Colors.redAccent,
                        label: "Reset All",
                        onTap: () => provider.resetGrid(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: provider.isRunning
                          ? null
                          : () async {
                              await provider.runAlgorithm();
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => ResultDialog(
                                    isSuccess: provider.pathLength > 0,
                                    time: provider.executionTime,
                                    visited: provider.visitedCount,
                                    length: provider.pathLength,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.start,
                        disabledBackgroundColor: Colors.grey[800],
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: provider.isRunning ? 0 : 6,
                      ),
                      icon: provider.isRunning
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 28),
                      label: Text(
                        provider.isRunning
                            ? "PROCESSING..."
                            : "START VISUALIZATION",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrushSelector(
    BuildContext context,
    VisualizerProvider provider, {
    required String label,
    required bool isWeight,
    required bool isActive,
    required Color color,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => provider.toggleBrushType(isWeight),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          border: Border.all(
            color: isActive ? color : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildContainerDivider() {
    return Container(height: 30, width: 1, color: Colors.white12);
  }

  Widget _buildCircleBtn({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: _buildCircleBtnContent(icon: icon, color: color, label: label),
    );
  }

  Widget _buildCircleBtnContent({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }
}
