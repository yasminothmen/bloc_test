import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final int completedLessons;
  final int totalLessons;

  const CustomProgressBar({
    super.key,
    required this.completedLessons,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    double progress = completedLessons / totalLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0), // fond gris clair
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$completedLessons/$totalLessons lessons",
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}
