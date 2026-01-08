/// MainMenu Screen - Mission Control Dashboard
///
/// Modern spy-themed game hub featuring:
/// - Agent profile header with stats
/// - Daily target card
/// - Mission grid (game modes)
/// - Utility footer
///
/// Full port of MainMenu.kt from yakkiedu Kotlin project.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/main_menu_models.dart';
import '../../widgets/agent_profile_header.dart';
import '../../widgets/daily_target_card.dart';
import '../../widgets/mistakes_review_card.dart';
import '../../widgets/mission_card.dart';
import '../../widgets/utility_button.dart';
import '../cloze/cloze_screen.dart';
import '../sniper/sniper_screen.dart';
import '../scrambler/scrambler_screen.dart';
import '../memory/memory_screen.dart';
import '../detective/detective_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../intel_reader/intel_reader_screen.dart';
import '../library/library_management_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final UserProfile? currentUser;
  final VoidCallback? onLogout;
  final VoidCallback? onProfileClick;
  final VoidCallback? onSettingsClick;

  const MainMenuScreen({
    super.key,
    this.currentUser,
    this.onLogout,
    this.onProfileClick,
    this.onSettingsClick,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  // Dashboard state (in real app this would come from a ViewModel/Provider)
  MainDashboardState _dashboardState = const MainDashboardState(
    userName: 'Agent Shadow',
    userInitials: 'AS',
    userLevel: 'Field Agent',
    cefrLevel: 'A1',
    totalXp: 1250,
    streakDays: 7,
    levelProgress: 0.45,
    xpToNextLevel: 750,
    dailyXpEarned: 45,
    dailyTarget: 100,
    dailyProgress: 0.45,
    mistakeCount: 3,
  );

  // Navigation states for full-screen game modes
  String? _activeScreen;

  void _navigateTo(String screen) {
    setState(() => _activeScreen = screen);
  }

  void _goBack() {
    setState(() => _activeScreen = null);
  }

  @override
  Widget build(BuildContext context) {
    // Handle full-screen game modes
    if (_activeScreen != null) {
      return _buildActiveScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Agent Profile Header
              AgentProfileHeader(
                state: _dashboardState,
                currentUser: widget.currentUser,
                onLogout: widget.onLogout ?? () {},
                onProfileClick: widget.onProfileClick ?? () {},
                onSettingsClick: widget.onSettingsClick ?? () {},
              ),
              const SizedBox(height: 20),

              // Daily Target Card
              DailyTargetCard(
                dailyXpEarned: _dashboardState.dailyXpEarned,
                dailyTarget: _dashboardState.dailyTarget,
                progress: _dashboardState.dailyProgress,
              ),
              const SizedBox(height: 20),

              // Mistakes Review (if any)
              if (_dashboardState.mistakeCount > 0) ...[
                MistakesReviewCard(
                  mistakeCount: _dashboardState.mistakeCount,
                  onTap: () => _navigateTo('mistakes'),
                ),
                const SizedBox(height: 20),
              ],

              // MISSIONS Section
              const Text(
                'MISSIONS',
                style: TextStyle(
                  color: AppColors.steelBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              // Missions Grid
              _buildMissionsGrid(),
              const SizedBox(height: 20),

              // UTILITIES Section
              const Text(
                'UTILITIES',
                style: TextStyle(
                  color: AppColors.steelBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              // Utilities Row
              _buildUtilitiesRow(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionsGrid() {
    return Column(
      children: [
        // Row 1: Memory + Scrambler
        Row(
          children: [
            Expanded(
              child: MissionCard(
                title: 'Secret Files',
                subtitle: 'Memory Match',
                icon: Icons.psychology,
                color: AppColors.accentBlue,
                onTap: () => _navigateTo('memory'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MissionCard(
                title: 'Decoder',
                subtitle: 'Word Scrambler',
                icon: Icons.shuffle,
                color: AppColors.accentOrange,
                onTap: () => _navigateTo('scrambler'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Sniper + Detective
        Row(
          children: [
            Expanded(
              child: MissionCard(
                title: 'SNIPER',
                subtitle: 'L1 Interference',
                icon: Icons.gps_fixed,
                color: AppColors.accentRed,
                onTap: () => _navigateTo('sniper'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MissionCard(
                title: 'Inspector',
                subtitle: 'Sentence Analysis',
                icon: Icons.search,
                color: AppColors.accentPurple,
                onTap: () => _navigateTo('detective'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Cloze + Intel Reader
        Row(
          children: [
            Expanded(
              child: MissionCard(
                title: 'Cloze Drills',
                subtitle: 'Fill-in-the-Blank',
                icon: Icons.edit,
                color: AppColors.accentTeal,
                onTap: () => _navigateTo('cloze'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MissionCard(
                title: 'Intel Reader',
                subtitle: 'Reading Mission',
                icon: Icons.menu_book,
                color: AppColors.accentGreen,
                onTap: () => _navigateTo('intel_reader'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 4: Teacher Mode
        Row(
          children: [
            Expanded(
              child: MissionCard(
                title: 'Teacher Mode',
                subtitle: 'Create Missions',
                icon: Icons.school,
                color: AppColors.accentCyan,
                onTap: () => _navigateTo('teacher_mode'),
              ),
            ),
            const SizedBox(width: 12),
            // Placeholder for future mode
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildUtilitiesRow() {
    return Row(
      children: [
        Expanded(
          child: UtilityButton(
            emoji: '',
            label: 'Libraries',
            onTap: () => _navigateTo('library'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: UtilityButton(
            emoji: '',
            label: 'Dictionary',
            onTap: () => _navigateTo('dictionary'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: UtilityButton(
            emoji: '',
            label: 'Lab',
            onTap: () => _navigateTo('lab'),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveScreen() {
    return Stack(
      children: [
        switch (_activeScreen) {
          'memory' => const MemoryScreen(),
          'scrambler' => const ScramblerScreen(),
          'sniper' => const SniperScreen(),
          'detective' => const DetectiveScreen(),
          'cloze' => const ClozeScreen(),
          'intel_reader' => const IntelReaderScreen(),
          'teacher_mode' => const IntelReaderScreen(isTeacherMode: true),
          'library' => const LibraryManagementScreen(),
          'dictionary' => const DictionaryScreen(),
          'mistakes' => const ScramblerScreen(), // Mistakes mode
          'lab' => const DetectiveScreen(), // Lab/TextWork mode
          _ => const Center(child: Text('Unknown screen')),
        },
        // Close button
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: FloatingActionButton(
              onPressed: _goBack,
              backgroundColor: AppColors.errorRed,
              mini: true,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
