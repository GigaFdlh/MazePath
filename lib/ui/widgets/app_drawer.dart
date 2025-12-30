import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/visualizer_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VisualizerProvider>(context);

    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // --- HEADER ---
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gridBackground, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.map_rounded, size: 48, color: AppColors.start),
                SizedBox(height: 10),
                Text(
                  "MazePath Guide",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // --- SECTION 1: BRUSH TYPE ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Brush Type",
              style: TextStyle(
                color: AppColors.start,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Option 1: Wall
          ListTile(
            leading: Icon(
              !provider.isWeightBrush
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: !provider.isWeightBrush ? AppColors.start : Colors.grey,
            ),
            title: const Text(
              "Wall (Block)",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Impassable obstacle",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Container(width: 20, height: 20, color: AppColors.wall),
            tileColor: !provider.isWeightBrush ? AppColors.gridBackground : null,
            onTap: () {
              provider.toggleBrushType(false);
              Navigator.pop(context);
            },
          ),

          // Option 2: Mud
          ListTile(
            leading: Icon(
              provider.isWeightBrush
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: provider.isWeightBrush ? AppColors.start : Colors.grey,
            ),
            title: const Text(
              "Mud (Weight)",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "High cost (Cost: 5)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Container(width: 20, height: 20, color: AppColors.weight),
            tileColor: provider.isWeightBrush ? AppColors.gridBackground : null,
            onTap: () {
              provider.toggleBrushType(true);
              Navigator.pop(context);
            },
          ),

          const Divider(color: Colors.grey),

          // --- SECTION 2: BRUSH SIZE ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              "Brush Size",
              style: TextStyle(
                color: AppColors.start,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Slider(
            value: provider.wallBrushSize.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            activeColor: AppColors.start,
            inactiveColor: AppColors.gridBackground,
            label: "${provider.wallBrushSize.toInt()}",
            onChanged: (val) => provider.setBrushSize(val),
          ),

          const Divider(color: Colors.grey),

          // --- SECTION 3: MOVEMENT LOGIC (FITUR BARU) ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              "Movement Logic",
              style: TextStyle(
                color: AppColors.start,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          SwitchListTile(
            title: const Text("Allow Diagonal", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Move in 8 directions", style: TextStyle(color: Colors.grey, fontSize: 12)),
            activeThumbColor: AppColors.start,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: provider.allowDiagonal,
            onChanged: (val) {
              provider.toggleDiagonal(val);
            },
            secondary: Icon(
              Icons.directions, 
              color: provider.allowDiagonal ? AppColors.start : Colors.grey
            ),
          ),
          
          const Divider(color: Colors.grey),

          // --- SECTION 4: HOW TO USE ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "How to Use",
              style: TextStyle(
                color: AppColors.start,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _buildInfoTile(
            Icons.touch_app,
            "Basic Controls",
            "1. Drag Green (Start) & Red (End).\n"
                "2. Select Brush: Wall or Mud.\n"
                "3. Draw on grid.\n"
                "4. Choose Algorithm (Dashboard).\n"
                "5. Press 'Start Visualization'.",
          ),

          const Divider(color: Colors.grey),

          // --- SECTION 5: LEGEND & ALGORITHMS ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Legend & Algorithms",
              style: TextStyle(
                color: AppColors.start,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _buildInfoTile(
            Icons.block,
            "Wall (Black)",
            "Absolute barrier. The algorithm must find a path around it.",
          ),
          _buildInfoTile(
            Icons.terrain,
            "Mud (Brown)",
            "Heavy terrain. Costs 5x movement points. Smart algorithms (A*, Dijkstra) will avoid it if possible.",
          ),

          _buildInfoTile(
            Icons.bolt,
            "A* (A-Star)",
            "Best Choice. Uses heuristics to estimate distance. Very fast and efficient.",
          ),
          _buildInfoTile(
            Icons.radar,
            "Dijkstra",
            "Guarantees shortest path. Explores all directions evenly. Slower than A* but thorough.",
          ),

          _buildInfoTile(
            Icons.wifi_tethering,
            "BFS (Breadth-First)",
            "Explores layer by layer like water. Guarantees shortest path by steps, but ignores Mud weight (treats it like normal ground).",
          ),
          _buildInfoTile(
            Icons.call_split,
            "DFS (Depth-First)",
            "Explores as deep as possible before backtracking. Does NOT guarantee the shortest path. Often results in long, winding routes.",
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String desc) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            desc,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
        ),
      ],
    );
  }
}