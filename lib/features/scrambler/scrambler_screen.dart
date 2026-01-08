/// Scrambler Screen - Sentence builder game
///
/// Features:
/// - Pool of scrambled words (tap to place)
/// - Sentence area (tap to remove)
/// - Smart cursor for insertion
/// - AI validation
/// - Session-based gameplay with XP
///
/// Port of ScramblerOverlay.kt from yakkiedu.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/scrambler_models.dart';

class ScramblerScreen extends StatefulWidget {
  const ScramblerScreen({super.key});

  @override
  State<ScramblerScreen> createState() => _ScramblerScreenState();
}

class _ScramblerScreenState extends State<ScramblerScreen> {
  ScramblerGameState _state = const ScramblerGameState();
  List<int> _placedTokens = [];
  int? _insertionIndex;

  // Demo sentences for testing
  final List<Map<String, dynamic>> _demoSentences = [
    {
      'original': 'I go to school every day',
      'scrambled': ['every', 'go', 'I', 'school', 'day', 'to'],
      'alternatives': ['Every day I go to school'],
    },
    {
      'original': 'She is reading a book',
      'scrambled': ['reading', 'a', 'She', 'is', 'book'],
      'alternatives': [],
    },
    {
      'original': 'They have finished their homework',
      'scrambled': ['finished', 'They', 'homework', 'have', 'their'],
      'alternatives': [],
    },
    {
      'original': 'We will visit Paris next summer',
      'scrambled': ['Paris', 'will', 'next', 'We', 'summer', 'visit'],
      'alternatives': ['Next summer we will visit Paris'],
    },
    {
      'original': 'He has been working here for five years',
      'scrambled': ['five', 'has', 'He', 'working', 'for', 'here', 'years', 'been'],
      'alternatives': [],
    },
  ];

  int _currentSentenceIndex = 0;

  void _startSession() {
    _loadNextSentence();
    setState(() {
      _state = _state.copyWith(
        screenState: GameScreenState.playing,
        currentQuestionIndex: 0,
        sessionScore: 0,
      );
    });
  }

  void _loadNextSentence() {
    final sentence = _demoSentences[_currentSentenceIndex % _demoSentences.length];
    setState(() {
      _state = _state.copyWith(
        originalSentence: sentence['original'] as String,
        scrambledWords: List<String>.from(sentence['scrambled'] as List),
        alternatives: List<String>.from(sentence['alternatives'] as List),
        isSubmitted: false,
        isHintUsed: false,
        validationResult: null,
        feedbackMessage: null,
        showErrors: false,
        sentenceHasError: false,
        isGenerating: false,
      );
      _placedTokens = [];
      _insertionIndex = null;
    });
  }

  void _placeToken(int index) {
    if (_state.isSubmitted) return;
    if (_placedTokens.contains(index)) return;

    setState(() {
      final insertAt = _insertionIndex ?? _placedTokens.length;
      _placedTokens.insert(insertAt.clamp(0, _placedTokens.length), index);
      _insertionIndex = insertAt + 1;
    });
  }

  void _removeToken(int placementIndex) {
    if (_state.isSubmitted) return;
    if (_state.lockedTokens.contains(_placedTokens[placementIndex])) return;

    setState(() {
      _placedTokens.removeAt(placementIndex);
      if (_insertionIndex != null && placementIndex < _insertionIndex!) {
        _insertionIndex = _insertionIndex! - 1;
      }
    });
  }

  void _setInsertionPoint(int index) {
    setState(() {
      _insertionIndex = index;
    });
  }

  void _submitAnswer() {
    // Build user sentence
    final userSentence = _placedTokens
        .map((i) => _state.scrambledWords[i])
        .join(' ');

    final isCorrect = userSentence.toLowerCase() ==
            _state.originalSentence?.toLowerCase() ||
        _state.alternatives.any(
            (alt) => alt.toLowerCase() == userSentence.toLowerCase());

    final result = ScramblerResult(
      isCorrect: isCorrect,
      scorePercent: isCorrect ? 100 : 0,
      correctCount: isCorrect ? _state.scrambledWords.length : 0,
      totalCount: _state.scrambledWords.length,
      message: isCorrect ? 'Perfect!' : 'Try again',
    );

    setState(() {
      _state = _state.copyWith(
        isSubmitted: true,
        validationResult: result,
        screenState: GameScreenState.feedback,
        sessionScore:
            isCorrect ? _state.sessionScore + 1 : _state.sessionScore,
      );
    });
  }

  void _nextQuestion() {
    _currentSentenceIndex++;
    if (_state.currentQuestionIndex >= _state.sessionLength - 1) {
      setState(() {
        _state = _state.copyWith(screenState: GameScreenState.finished);
      });
    } else {
      _loadNextSentence();
      setState(() {
        _state = _state.copyWith(
          currentQuestionIndex: _state.currentQuestionIndex + 1,
          screenState: GameScreenState.playing,
        );
      });
    }
  }

  void _useHint() {
    // Show correct order
    setState(() {
      _placedTokens = List.generate(_state.scrambledWords.length, (i) => i);
      _state = _state.copyWith(isHintUsed: true);
    });
  }

  void _restart() {
    _currentSentenceIndex = 0;
    setState(() {
      _state = const ScramblerGameState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: switch (_state.screenState) {
          GameScreenState.setup => _buildSetupScreen(),
          GameScreenState.playing ||
          GameScreenState.validating ||
          GameScreenState.feedback =>
            _buildGameScreen(),
          GameScreenState.finished => _buildResultScreen(),
        },
      ),
    );
  }

  Widget _buildSetupScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Scrambler',
            style: TextStyle(
              color: AppColors.offWhite,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build sentences from words',
            style: TextStyle(
              color: AppColors.steelBlue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Level selection
          _buildSectionTitle('Level'),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: GrammarOptions.levels.map((level) {
              final isSelected = _state.selectedLevel == level;
              return ChoiceChip(
                label: Text(level),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _state = _state.copyWith(selectedLevel: level);
                  });
                },
                selectedColor: AppColors.accentGold,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.darkNavy : AppColors.offWhite,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Tense selection
          _buildSectionTitle('Grammar Tense'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GrammarOptions.tenses.take(5).map((tense) {
              final isSelected = _state.selectedTense == tense;
              return ChoiceChip(
                label: Text(tense),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _state = _state.copyWith(selectedTense: tense);
                  });
                },
                selectedColor: AppColors.accentPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.offWhite,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Sentence type
          _buildSectionTitle('Sentence Type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GrammarOptions.sentenceTypes.map((type) {
              final isSelected = _state.selectedType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _state = _state.copyWith(selectedType: type);
                  });
                },
                selectedColor: AppColors.accentBlue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.offWhite,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Session length
          _buildSectionTitle('Session Length'),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [5, 10, 25].map((count) {
              final isSelected = _state.sessionLength == count;
              return ChoiceChip(
                label: Text('$count'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _state = _state.copyWith(sessionLength: count);
                  });
                },
                selectedColor: AppColors.accentGreen,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.offWhite,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          // Start button
          SizedBox(
            width: 200,
            height: 56,
            child: ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.offWhite,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final pool = List.generate(
      _state.scrambledWords.length,
      (i) => i,
    ).where((i) => !_placedTokens.contains(i)).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _state.progressPercent,
                  backgroundColor: AppColors.slateGray,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Score: ${_state.sessionScore}/${_state.currentQuestionIndex + (_state.isSubmitted ? 1 : 0)}',
                style: const TextStyle(
                  color: AppColors.steelBlue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Build the sentence',
            style: TextStyle(
              color: AppColors.offWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Tap words in the correct order',
            style: TextStyle(
              color: AppColors.steelBlue,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Sentence area
          Text(
            'Sentence:',
            style: TextStyle(
              color: AppColors.accentGold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withAlpha(51),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentBlue.withAlpha(128),
                width: 2,
              ),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (_placedTokens.isEmpty)
                  Text(
                    '<- Tap words below',
                    style: TextStyle(
                      color: AppColors.steelBlue.withAlpha(128),
                      fontSize: 16,
                    ),
                  )
                else
                  for (int i = 0; i < _placedTokens.length; i++) ...[
                    if (i == 0 && !_state.isSubmitted)
                      _buildCursor(0),
                    _buildWordChip(
                      _state.scrambledWords[_placedTokens[i]],
                      isInSentence: true,
                      isCorrect: _state.validationResult?.isCorrect,
                      onTap: () => _removeToken(i),
                    ),
                    if (!_state.isSubmitted) _buildCursor(i + 1),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Divider(color: AppColors.slateGray),
          const SizedBox(height: 16),

          // Pool area
          Text(
            'Available words:',
            style: TextStyle(
              color: AppColors.accentOrange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: pool.isEmpty
                    ? [
                        const Text(
                          'All words used',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 16,
                          ),
                        ),
                      ]
                    : pool.map((i) {
                        return _buildWordChip(
                          _state.scrambledWords[i],
                          isInSentence: false,
                          onTap: () => _placeToken(i),
                        );
                      }).toList(),
              ),
            ),
          ),

          // Feedback area
          if (_state.isSubmitted && _state.validationResult != null) ...[
            const SizedBox(height: 16),
            _buildFeedbackArea(),
          ],

          // Check button
          if (!_state.isSubmitted && pool.isEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'CHECK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCursor(int index) {
    final isActive = _insertionIndex == index ||
        (_insertionIndex == null && index == _placedTokens.length);
    return GestureDetector(
      onTap: () => _setInsertionPoint(index),
      child: Container(
        width: isActive ? 4 : 2,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentBlue
              : AppColors.steelBlue.withAlpha(128),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildWordChip(
    String text, {
    required bool isInSentence,
    bool? isCorrect,
    required VoidCallback onTap,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isCorrect == true) {
      bgColor = AppColors.accentGreen.withAlpha(77);
      borderColor = AppColors.accentGreen;
      textColor = AppColors.accentGreen;
    } else if (isCorrect == false) {
      bgColor = AppColors.errorRed.withAlpha(77);
      borderColor = AppColors.errorRed;
      textColor = AppColors.errorRed;
    } else if (isInSentence) {
      bgColor = const Color(0xFFBBDEFB);
      borderColor = AppColors.accentBlue;
      textColor = AppColors.darkNavy;
    } else {
      bgColor = const Color(0xFFFFF9C4);
      borderColor = AppColors.accentOrange;
      textColor = AppColors.darkNavy;
    }

    return GestureDetector(
      onTap: _state.isSubmitted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackArea() {
    final result = _state.validationResult!;
    final isCorrect = result.isCorrect;

    return Column(
      children: [
        Text(
          result.message,
          style: TextStyle(
            color: isCorrect ? AppColors.accentGreen : AppColors.errorRed,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!isCorrect && _state.originalSentence != null) ...[
          const SizedBox(height: 8),
          Text(
            'Correct: ${_state.originalSentence}',
            style: const TextStyle(
              color: AppColors.offWhite,
              fontSize: 16,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          height: 48,
          child: ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _state.isLastQuestion ? AppColors.accentPurple : AppColors.accentBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _state.isLastQuestion ? 'FINISH' : 'NEXT',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    final scorePercent = _state.sessionLength > 0
        ? (_state.sessionScore * 100 / _state.sessionLength).round()
        : 0;

    String emoji;
    if (scorePercent >= 90) {
      emoji = '';
    } else if (scorePercent >= 80) {
      emoji = '';
    } else if (scorePercent >= 60) {
      emoji = '';
    } else if (scorePercent >= 40) {
      emoji = '';
    } else {
      emoji = '';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            'Session Complete!',
            style: TextStyle(
              color: AppColors.offWhite,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${_state.sessionScore} / ${_state.sessionLength}',
            style: TextStyle(
              color: AppColors.accentGold,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$scorePercent%',
            style: const TextStyle(
              color: AppColors.steelBlue,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 56,
            child: ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
