/// AgentProfileHeader Widget - User profile card with stats
///
/// Shows avatar, name, level, XP, streak, and progress bar.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/main_menu_models.dart';
import 'stat_pill.dart';

class AgentProfileHeader extends StatelessWidget {
  final MainDashboardState state;
  final UserProfile? currentUser;
  final VoidCallback onLogout;
  final VoidCallback onProfileClick;
  final VoidCallback onSettingsClick;

  const AgentProfileHeader({
    super.key,
    required this.state,
    this.currentUser,
    required this.onLogout,
    required this.onProfileClick,
    required this.onSettingsClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.midnightBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top row: Avatar + Name + Stats
          Row(
            children: [
              // Avatar + Name (tappable)
              Expanded(
                child: GestureDetector(
                  onTap: onProfileClick,
                  child: Row(
                    children: [
                      // Avatar circle
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.slateGray,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            currentUser?.initials ?? state.userInitials,
                            style: const TextStyle(
                              color: AppColors.offWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.displayName ?? state.userName,
                            style: const TextStyle(
                              color: AppColors.offWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            state.userLevel,
                            style: const TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Stats pills
              Row(
                children: [
                  // XP Pill
                  StatPill(
                    value: '${state.totalXp}',
                    label: 'XP',
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(width: 8),
                  // Streak Pill
                  if (state.streakDays > 0) ...[
                    StatPill(
                      icon: Icons.local_fire_department,
                      value: '${state.streakDays}',
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Settings button
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: AppColors.steelBlue,
                    ),
                    onPressed: onSettingsClick,
                  ),
                  // Logout button
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.errorRed,
                    ),
                    onPressed: onLogout,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Level progress bar
          Row(
            children: [
              Text(
                state.cefrLevel,
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.levelProgress,
                    minHeight: 8,
                    backgroundColor: AppColors.slateGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.xpToNextLevel} XP to next',
                style: const TextStyle(
                  color: AppColors.steelBlue,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
