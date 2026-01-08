/// Sniper Models - Data models for Sniper Mode (L1 Interference)
///
/// Mirrors the Kotlin models in yakki-core for consistency.
/// Sniper Mode targets L1 interference patterns - common errors
/// that speakers of specific native languages make in English.

/// Source language enum.
enum L1Source { hebrew, russian, arabic }

/// Error category for interleaving.
enum ErrorCategory {
  syntax,
  preposition,
  lexical,
  tense,
  article,
  wordOrder
}

/// L1 Trap - an interference pattern to practice.
class L1Trap {
  final String id;
  final L1Source l1Source;
  final ErrorCategory category;
  final String context;
  final String errorPattern;
  final String correctPattern;
  final String explanation;
  final Map<String, String> explanations;

  const L1Trap({
    required this.id,
    required this.l1Source,
    required this.category,
    required this.context,
    required this.errorPattern,
    required this.correctPattern,
    required this.explanation,
    this.explanations = const {},
  });

  String getExplanation(String localeCode) {
    return explanations[localeCode] ?? explanations['en'] ?? explanation;
  }

  factory L1Trap.fromJson(Map<String, dynamic> json) {
    return L1Trap(
      id: json['id'] as String,
      l1Source: L1Source.values.firstWhere(
        (e) => e.name == (json['l1Source'] as String).toLowerCase(),
        orElse: () => L1Source.hebrew,
      ),
      category: ErrorCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String).toLowerCase(),
        orElse: () => ErrorCategory.syntax,
      ),
      context: json['context'] as String,
      errorPattern: json['errorPattern'] as String,
      correctPattern: json['correctPattern'] as String,
      explanation: json['explanation'] as String,
      explanations: Map<String, String>.from(json['explanations'] ?? {}),
    );
  }
}

/// A single Sniper round.
class SniperRound {
  final L1Trap trap;
  final double threatScore;
  final bool isNovelty;

  const SniperRound({
    required this.trap,
    required this.threatScore,
    required this.isNovelty,
  });
}

/// Sniper game state.
class SniperGameState {
  final List<SniperRound> currentBatch;
  final int currentIndex;
  final double timeLeftPercent;
  final bool isOvertime;
  final int coverIntegrity;
  final bool isGameFinished;
  final int totalCorrect;
  final int totalWrong;
  final int xpAwarded;

  const SniperGameState({
    this.currentBatch = const [],
    this.currentIndex = 0,
    this.timeLeftPercent = 1.0,
    this.isOvertime = false,
    this.coverIntegrity = 100,
    this.isGameFinished = false,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.xpAwarded = 0,
  });

  SniperRound? get currentRound =>
      currentIndex < currentBatch.length ? currentBatch[currentIndex] : null;

  double get batchProgress =>
      currentBatch.isEmpty ? 0 : currentIndex / currentBatch.length;

  bool get hasNextQuestion => currentIndex < currentBatch.length - 1;

  int get questionsRemaining =>
      (currentBatch.length - currentIndex).clamp(0, currentBatch.length);

  bool get isCoverCritical => coverIntegrity <= 25;
  bool get isCoverBlown => coverIntegrity <= 0;

  double get accuracy =>
      totalCorrect + totalWrong > 0
          ? totalCorrect / (totalCorrect + totalWrong)
          : 0;

  SniperGameState copyWith({
    List<SniperRound>? currentBatch,
    int? currentIndex,
    double? timeLeftPercent,
    bool? isOvertime,
    int? coverIntegrity,
    bool? isGameFinished,
    int? totalCorrect,
    int? totalWrong,
    int? xpAwarded,
  }) {
    return SniperGameState(
      currentBatch: currentBatch ?? this.currentBatch,
      currentIndex: currentIndex ?? this.currentIndex,
      timeLeftPercent: timeLeftPercent ?? this.timeLeftPercent,
      isOvertime: isOvertime ?? this.isOvertime,
      coverIntegrity: coverIntegrity ?? this.coverIntegrity,
      isGameFinished: isGameFinished ?? this.isGameFinished,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalWrong: totalWrong ?? this.totalWrong,
      xpAwarded: xpAwarded ?? this.xpAwarded,
    );
  }
}

/// Sniper rank based on performance.
enum SniperRank {
  gold('Ghost Protocol', '🥇', 2.0),
  silver('Clean Extraction', '🥈', 1.5),
  bronze('Scraped Through', '🥉', 1.0),
  compromised('Cover Blown', '💥', 0.5);

  final String displayName;
  final String emoji;
  final double xpMultiplier;

  const SniperRank(this.displayName, this.emoji, this.xpMultiplier);

  static SniperRank fromGameState(SniperGameState state) {
    if (state.coverIntegrity <= 0) return SniperRank.compromised;
    if (state.coverIntegrity >= 100 && !state.isOvertime) return SniperRank.gold;
    if (state.coverIntegrity >= 50 && !state.isOvertime) return SniperRank.silver;
    return SniperRank.bronze;
  }
}

/// Sniper configuration constants.
class SniperConfig {
  static const int missionTimeSeconds = 45;
  static const int timerTickMs = 100;
  static const int coverPenaltyPerError = 15;
  static const int batchSize = 5;
  static const int silverThreshold = 50;
  static const int bronzeThreshold = 1;
}
