/// StatPill Widget - Small stat indicator pill
///
/// Shows XP, streak, or other stats in a compact pill format.

import 'package:flutter/material.dart';

class StatPill extends StatelessWidget {
  final IconData? icon;
  final String value;
  final String? label;
  final Color color;

  const StatPill({
    super.key,
    this.icon,
    required this.value,
    this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(51), // 0.2 alpha
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: TextStyle(
                color: color.withAlpha(204), // 0.8 alpha
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
