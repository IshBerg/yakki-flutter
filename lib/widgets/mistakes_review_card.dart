/// MistakesReviewCard Widget - Mistakes review prompt
///
/// Shows when user has pending mistakes to review.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MistakesReviewCard extends StatelessWidget {
  final int mistakeCount;
  final VoidCallback onTap;

  const MistakesReviewCard({
    super.key,
    required this.mistakeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037).withAlpha(77), // Brown 0.3 alpha
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              '',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review Mistakes',
                    style: TextStyle(
                      color: AppColors.offWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$mistakeCount items need attention',
                    style: const TextStyle(
                      color: AppColors.steelBlue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$mistakeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
