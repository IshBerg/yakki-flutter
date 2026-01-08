/// UtilityButton Widget - Footer utility button
///
/// A simple button for utilities like Library, Dictionary, Lab.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UtilityButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const UtilityButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.slateGray.withAlpha(77), // 0.3 alpha
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.offWhite,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
