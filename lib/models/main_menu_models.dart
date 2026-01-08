/// Main Menu Models - State and data models for MainMenu/Dashboard
///
/// Mirrors the Kotlin models for MainViewModel state.

/// User profile data
class UserProfile {
  final String id;
  final String displayName;
  final String email;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
  });

  String get initials {
    if (displayName.isEmpty) return '??';
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.substring(0, displayName.length.clamp(0, 2)).toUpperCase();
  }
}

/// Main Dashboard State
class MainDashboardState {
  final String userName;
  final String userInitials;
  final String userLevel;
  final String cefrLevel;
  final int totalXp;
  final int streakDays;
  final double levelProgress;
  final int xpToNextLevel;
  final int dailyXpEarned;
  final int dailyTarget;
  final double dailyProgress;
  final int mistakeCount;

  const MainDashboardState({
    this.userName = 'Agent',
    this.userInitials = 'AG',
    this.userLevel = 'Field Agent',
    this.cefrLevel = 'A1',
    this.totalXp = 0,
    this.streakDays = 0,
    this.levelProgress = 0.0,
    this.xpToNextLevel = 100,
    this.dailyXpEarned = 0,
    this.dailyTarget = 100,
    this.dailyProgress = 0.0,
    this.mistakeCount = 0,
  });

  MainDashboardState copyWith({
    String? userName,
    String? userInitials,
    String? userLevel,
    String? cefrLevel,
    int? totalXp,
    int? streakDays,
    double? levelProgress,
    int? xpToNextLevel,
    int? dailyXpEarned,
    int? dailyTarget,
    double? dailyProgress,
    int? mistakeCount,
  }) {
    return MainDashboardState(
      userName: userName ?? this.userName,
      userInitials: userInitials ?? this.userInitials,
      userLevel: userLevel ?? this.userLevel,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      levelProgress: levelProgress ?? this.levelProgress,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      dailyXpEarned: dailyXpEarned ?? this.dailyXpEarned,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      mistakeCount: mistakeCount ?? this.mistakeCount,
    );
  }
}

/// Mission card data
class MissionData {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final int colorValue;
  final bool isEnabled;

  const MissionData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.colorValue,
    this.isEnabled = true,
  });
}

/// Help content types for dialogs
enum HelpContent {
  scrambler,
  detective,
  sniper,
  memory,
  cloze,
  intelReader,
}
