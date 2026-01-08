/// Cloze Models - Data models for Cloze Drills game mode
///
/// Mirrors the Kotlin models in yakki-core for consistency.
/// These will eventually be generated from shared schema.

/// A single cloze test question.
class ClozeQuestion {
  final String id;
  final String originalSentence;
  final String maskedSentence;
  final String correctAnswer;
  final List<String> options;
  final String? translation;
  final double difficulty;

  const ClozeQuestion({
    required this.id,
    required this.originalSentence,
    required this.maskedSentence,
    required this.correctAnswer,
    required this.options,
    this.translation,
    this.difficulty = 1.0,
  });

  factory ClozeQuestion.fromJson(Map<String, dynamic> json) {
    return ClozeQuestion(
      id: json['id'] as String,
      originalSentence: json['originalSentence'] as String,
      maskedSentence: json['maskedSentence'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: List<String>.from(json['options']),
      translation: json['translation'] as String?,
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalSentence': originalSentence,
        'maskedSentence': maskedSentence,
        'correctAnswer': correctAnswer,
        'options': options,
        'translation': translation,
        'difficulty': difficulty,
      };
}

/// A collection of cloze questions from a library.
class ClozeDrill {
  final String libraryId;
  final String libraryName;
  final String libraryEmoji;
  final String cefrLevel;
  final List<ClozeQuestion> questions;

  const ClozeDrill({
    required this.libraryId,
    required this.libraryName,
    required this.libraryEmoji,
    required this.cefrLevel,
    required this.questions,
  });

  int get totalQuestions => questions.length;

  factory ClozeDrill.fromJson(Map<String, dynamic> json) {
    return ClozeDrill(
      libraryId: json['libraryId'] as String,
      libraryName: json['libraryName'] as String,
      libraryEmoji: json['libraryEmoji'] as String,
      cefrLevel: json['cefrLevel'] as String,
      questions: (json['questions'] as List)
          .map((q) => ClozeQuestion.fromJson(q))
          .toList(),
    );
  }
}

/// Complete game state for Cloze Drills.
class ClozeGameState {
  final ClozeDrill? currentDrill;
  final int currentIndex;
  final int totalCorrect;
  final int totalWrong;
  final int streak;
  final int bestStreak;
  final int timeLeftSeconds;
  final bool isOvertime;
  final bool isGameFinished;
  final int xpAwarded;

  const ClozeGameState({
    this.currentDrill,
    this.currentIndex = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.timeLeftSeconds = 30,
    this.isOvertime = false,
    this.isGameFinished = false,
    this.xpAwarded = 0,
  });

  int get totalAnswered => totalCorrect + totalWrong;

  double get accuracy =>
      totalAnswered > 0 ? totalCorrect / totalAnswered : 0.0;

  double get progress =>
      currentDrill != null && currentDrill!.totalQuestions > 0
          ? currentIndex / currentDrill!.totalQuestions
          : 0.0;

  ClozeQuestion? get currentQuestion =>
      currentDrill?.questions.elementAtOrNull(currentIndex);

  ClozeGameState copyWith({
    ClozeDrill? currentDrill,
    int? currentIndex,
    int? totalCorrect,
    int? totalWrong,
    int? streak,
    int? bestStreak,
    int? timeLeftSeconds,
    bool? isOvertime,
    bool? isGameFinished,
    int? xpAwarded,
  }) {
    return ClozeGameState(
      currentDrill: currentDrill ?? this.currentDrill,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalWrong: totalWrong ?? this.totalWrong,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
      isOvertime: isOvertime ?? this.isOvertime,
      isGameFinished: isGameFinished ?? this.isGameFinished,
      xpAwarded: xpAwarded ?? this.xpAwarded,
    );
  }
}

/// Performance rank based on accuracy.
enum ClozeRank {
  perfect('Perfect', '🏆', 2.0),
  excellent('Excellent', '🥇', 1.5),
  good('Good', '🥈', 1.2),
  fair('Fair', '🥉', 1.0),
  needsPractice('Needs Practice', '📚', 0.5);

  final String displayName;
  final String emoji;
  final double xpMultiplier;

  const ClozeRank(this.displayName, this.emoji, this.xpMultiplier);

  static ClozeRank fromAccuracy(double accuracy, bool wasOvertime) {
    final adjustedAccuracy = wasOvertime ? accuracy * 0.9 : accuracy;
    if (adjustedAccuracy >= 1.0) return ClozeRank.perfect;
    if (adjustedAccuracy >= 0.9) return ClozeRank.excellent;
    if (adjustedAccuracy >= 0.7) return ClozeRank.good;
    if (adjustedAccuracy >= 0.5) return ClozeRank.fair;
    return ClozeRank.needsPractice;
  }
}

// Extension for safe element access
extension ListExtension<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
