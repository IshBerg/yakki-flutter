/// DailyTargetCard Widget - Daily XP target progress
///
/// Shows daily XP progress with animated gradient background.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DailyTargetCard extends StatefulWidget {
  final int dailyXpEarned;
  final int dailyTarget;
  final double progress;

  const DailyTargetCard({
    super.key,
    required this.dailyXpEarned,
    required this.dailyTarget,
    required this.progress,
  });

  @override
  State<DailyTargetCard> createState() => _DailyTargetCardState();
}

class _DailyTargetCardState extends State<DailyTargetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(DailyTargetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.accentGold.withAlpha(77), // 0.3 alpha
            AppColors.accentOrange.withAlpha(51), // 0.2 alpha
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DAILY TARGET',
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Earn ${widget.dailyTarget} XP today',
                    style: const TextStyle(
                      color: AppColors.offWhite,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.dailyXpEarned} / ${widget.dailyTarget}',
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 10,
                  backgroundColor: AppColors.midnightBlue.withAlpha(128),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentGold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
