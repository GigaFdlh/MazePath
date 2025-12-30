import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ResultDialog extends StatelessWidget {
  final bool isSuccess;
  final int time;
  final int visited;
  final int length;

  const ResultDialog({
    super.key,
    required this.isSuccess,
    this.time = 0,
    this.visited = 0,
    this.length = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSuccess
                    ? AppColors.start.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.emoji_events_rounded : Icons.cancel_rounded,
                size: 60,
                color: isSuccess ? AppColors.start : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              isSuccess ? "Target Found!" : "Dead End!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            if (!isSuccess)
              const Text(
                "The algorithm could not find a path to the target because it is blocked by walls.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: [
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  _buildRow(Icons.timer, "Computation Time", "$time ms"),
                  _buildRow(
                    Icons.visibility,
                    "Nodes Visited",
                    "$visited blocks",
                  ),
                  _buildRow(Icons.route, "Path Length", "$length steps"),
                ],
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gridBackground,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.start,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
