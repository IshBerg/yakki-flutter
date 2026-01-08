/// Scrambler Models - Data models for Scrambler game mode
///
/// Mirrors the Kotlin ScramblerModels.kt

/// Game screen state machine for Scrambler sessions.
enum GameScreenState {
  setup,      // Settings screen (level, session length)
  playing,    // Active gameplay (arrange tokens)
  validating, // AI Referee is checking the answer
  feedback,   // Result screen (correct/incorrect)
  finished,   // Session complete (final score)
}

/// Grammar options constants
class GrammarOptions {
  static const List<String> tenses = [
    'Any',
    'Present Simple',
    'Present Continuous',
    'Present Perfect',
    'Present Perfect Continuous',
    'Past Simple',
    'Past Continuous',
    'Past Perfect',
    'Past Perfect Continuous',
    'Future Simple',
    'Future Continuous',
    'Future Perfect',
    'Future Perfect Continuous',
  ];

  static const List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static const List<String> sentenceTypes = ['Statement', 'Question', 'Negative'];
  static const List<int> sessionLengths = [5, 10, 25, 50];
}

/// Scrambler game state
class ScramblerGameState {
  final GameScreenState screenState;
  final String selectedLevel;
  final String selectedTense;
  final String selectedType;
  final String selectedStructure;
  final int sessionLength;
  final int currentQuestionIndex;
  final int sessionScore;
  final bool isGenerating;
  final bool isSubmitted;
  final bool isHintUsed;
  final String? originalSentence;
  final List<String> alternatives;
  final List<String> scrambledWords;
  final List<int> placedTokens;
  final Set<int> lockedTokens;
  final int? insertionIndex;
  final ScramblerResult? validationResult;
  final String? feedbackMessage;
  final bool showErrors;
  final bool sentenceHasError;

  const ScramblerGameState({
    this.screenState = GameScreenState.setup,
    this.selectedLevel = 'A1',
    this.selectedTense = 'Any',
    this.selectedType = 'Statement',
    this.selectedStructure = 'Any',
    this.sessionLength = 5,
    this.currentQuestionIndex = 0,
    this.sessionScore = 0,
    this.isGenerating = false,
    this.isSubmitted = false,
    this.isHintUsed = false,
    this.originalSentence,
    this.alternatives = const [],
    this.scrambledWords = const [],
    this.placedTokens = const [],
    this.lockedTokens = const {},
    this.insertionIndex,
    this.validationResult,
    this.feedbackMessage,
    this.showErrors = false,
    this.sentenceHasError = false,
  });

  bool get isLastQuestion => currentQuestionIndex >= sessionLength - 1;
  double get progressPercent =>
      sessionLength > 0 ? (currentQuestionIndex + 1) / sessionLength : 0;

  ScramblerGameState copyWith({
    GameScreenState? screenState,
    String? selectedLevel,
    String? selectedTense,
    String? selectedType,
    String? selectedStructure,
    int? sessionLength,
    int? currentQuestionIndex,
    int? sessionScore,
    bool? isGenerating,
    bool? isSubmitted,
    bool? isHintUsed,
    String? originalSentence,
    List<String>? alternatives,
    List<String>? scrambledWords,
    List<int>? placedTokens,
    Set<int>? lockedTokens,
    int? insertionIndex,
    ScramblerResult? validationResult,
    String? feedbackMessage,
    bool? showErrors,
    bool? sentenceHasError,
  }) {
    return ScramblerGameState(
      screenState: screenState ?? this.screenState,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedTense: selectedTense ?? this.selectedTense,
      selectedType: selectedType ?? this.selectedType,
      selectedStructure: selectedStructure ?? this.selectedStructure,
      sessionLength: sessionLength ?? this.sessionLength,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      sessionScore: sessionScore ?? this.sessionScore,
      isGenerating: isGenerating ?? this.isGenerating,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isHintUsed: isHintUsed ?? this.isHintUsed,
      originalSentence: originalSentence ?? this.originalSentence,
      alternatives: alternatives ?? this.alternatives,
      scrambledWords: scrambledWords ?? this.scrambledWords,
      placedTokens: placedTokens ?? this.placedTokens,
      lockedTokens: lockedTokens ?? this.lockedTokens,
      insertionIndex: insertionIndex,
      validationResult: validationResult ?? this.validationResult,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      showErrors: showErrors ?? this.showErrors,
      sentenceHasError: sentenceHasError ?? this.sentenceHasError,
    );
  }
}

/// Scrambler validation result
class ScramblerResult {
  final bool isCorrect;
  final int scorePercent;
  final int correctCount;
  final int totalCount;
  final String message;
  final Map<int, bool> tokenResults;

  const ScramblerResult({
    required this.isCorrect,
    required this.scorePercent,
    required this.correctCount,
    required this.totalCount,
    required this.message,
    this.tokenResults = const {},
  });
}
