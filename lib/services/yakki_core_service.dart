/// Yakki Core Service - Bridge to native Kotlin code
///
/// Uses Platform Channels to communicate with yakki-core module.
/// This will eventually call into the shared Kotlin business logic.

import 'package:flutter/services.dart';

/// Service for communicating with yakki-core native module.
class YakkiCoreService {
  static const MethodChannel _channel = MethodChannel('com.yakki.core/cloze');

  /// Calculate XP for Cloze drill completion.
  Future<int> calculateClozeXP({
    required String cefrLevel,
    required int correctCount,
    required double accuracy,
    required bool wasOvertime,
  }) async {
    try {
      final result = await _channel.invokeMethod('calculateClozeXP', {
        'cefrLevel': cefrLevel,
        'correctCount': correctCount,
        'accuracy': accuracy,
        'wasOvertime': wasOvertime,
      });
      return result as int;
    } on PlatformException {
      // Fallback calculation if native code not available
      return _fallbackClozeXP(cefrLevel, correctCount, accuracy, wasOvertime);
    } on MissingPluginException {
      // Platform channel not implemented yet
      return _fallbackClozeXP(cefrLevel, correctCount, accuracy, wasOvertime);
    }
  }

  /// Fallback XP calculation (pure Dart).
  int _fallbackClozeXP(
    String cefrLevel,
    int correctCount,
    double accuracy,
    bool wasOvertime,
  ) {
    const baseXp = 10;

    final levelMultiplier = switch (cefrLevel.toUpperCase()) {
      'A1' => 1.0,
      'A2' => 1.2,
      'B1' => 1.5,
      'B2' => 2.0,
      'C1' => 3.0,
      'C2' => 5.0,
      _ => 1.0,
    };

    final accuracyBonus = switch (accuracy) {
      >= 1.0 => 2.0,
      >= 0.9 => 1.5,
      >= 0.7 => 1.2,
      _ => 1.0,
    };

    final timePenalty = wasOvertime ? 0.9 : 1.0;

    return (correctCount * baseXp * levelMultiplier * accuracyBonus * timePenalty)
        .toInt();
  }

  /// Get user's current level based on XP.
  Future<Map<String, dynamic>> getUserLevel(int totalXp) async {
    try {
      final result = await _channel.invokeMethod('getUserLevel', {
        'totalXp': totalXp,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException {
      return _fallbackGetUserLevel(totalXp);
    } on MissingPluginException {
      return _fallbackGetUserLevel(totalXp);
    }
  }

  /// Fallback level calculation (pure Dart).
  Map<String, dynamic> _fallbackGetUserLevel(int totalXp) {
    final levels = [
      {'code': 'A1', 'name': 'Novice', 'minXp': 0, 'maxXp': 500},
      {'code': 'A2', 'name': 'Apprentice', 'minXp': 500, 'maxXp': 1500},
      {'code': 'B1', 'name': 'Intermediate', 'minXp': 1500, 'maxXp': 3000},
      {'code': 'B2', 'name': 'Upper-Intermediate', 'minXp': 3000, 'maxXp': 5000},
      {'code': 'C1', 'name': 'Advanced', 'minXp': 5000, 'maxXp': 8000},
      {'code': 'C2', 'name': 'Master', 'minXp': 8000, 'maxXp': null},
    ];

    var currentLevel = levels.first;
    for (final level in levels) {
      if (totalXp >= (level['minXp'] as int)) {
        currentLevel = level;
      }
    }

    return currentLevel;
  }

  /// Validate cloze answer.
  bool validateAnswer(String userAnswer, String correctAnswer, {bool strictMode = false}) {
    final normalizedUser = userAnswer.trim();
    final normalizedCorrect = correctAnswer.trim();

    if (strictMode) {
      return normalizedUser == normalizedCorrect;
    } else {
      return normalizedUser.toLowerCase() == normalizedCorrect.toLowerCase();
    }
  }

  /// Calculate similarity between two strings (for feedback).
  double getSimilarity(String userAnswer, String correctAnswer) {
    final user = userAnswer.toLowerCase().trim();
    final correct = correctAnswer.toLowerCase().trim();

    if (user == correct) return 1.0;
    if (user.isEmpty || correct.isEmpty) return 0.0;

    final maxLen = user.length > correct.length ? user.length : correct.length;
    final distance = _levenshteinDistance(user, correct);

    return (1.0 - distance / maxLen).clamp(0.0, 1.0);
  }

  int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;

    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 0; i <= m; i++) dp[i][0] = i;
    for (var j = 0; j <= n; j++) dp[0][j] = j;

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[m][n];
  }
}
