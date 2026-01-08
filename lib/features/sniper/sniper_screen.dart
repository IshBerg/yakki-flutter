/// Sniper Screen - L1 Interference game mode
///
/// Features:
/// - Pattern identification (error vs correct)
/// - Timer-based gameplay with cover integrity
/// - "Soft Train, Hard Rank" philosophy
/// - L1-specific error patterns

import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/sniper_models.dart';

class SniperScreen extends StatefulWidget {
  const SniperScreen({super.key});

  @override
  State<SniperScreen> createState() => _SniperScreenState();
}

class _SniperScreenState extends State<SniperScreen> {
  SniperGameState _gameState = const SniperGameState();
  bool _isLoading = true;
  bool? _selectedIsError; // true = error pattern, false = correct
  Timer? _timer;

  // Demo rounds for testing
  final List<SniperRound> _demoRounds = [
    SniperRound(
      trap: L1Trap(
        id: 'he_1',
        l1Source: L1Source.hebrew,
        category: ErrorCategory.preposition,
        context: 'transport',
        errorPattern: 'I came by foot',
        correctPattern: 'I came on foot',
        explanation: 'In English we use "on foot", not "by foot"',
      ),
      threatScore: 75.0,
      isNovelty: true,
    ),
    SniperRound(
      trap: L1Trap(
        id: 'ru_1',
        l1Source: L1Source.russian,
        category: ErrorCategory.article,
        context: 'general',
        errorPattern: 'I like music',
        correctPattern: 'I like music',
        explanation: 'No article needed with general concepts',
      ),
      threatScore: 60.0,
      isNovelty: false,
    ),
    SniperRound(
      trap: L1Trap(
        id: 'he_2',
        l1Source: L1Source.hebrew,
        category: ErrorCategory.syntax,
        context: 'time',
        errorPattern: 'Yesterday I did go to school',
        correctPattern: 'Yesterday I went to school',
        explanation: 'Don\'t use "did" with past simple in statements',
      ),
      threatScore: 80.0,
      isNovelty: true,
    ),
    SniperRound(
      trap: L1Trap(
        id: 'ar_1',
        l1Source: L1Source.arabic,
        category: ErrorCategory.wordOrder,
        context: 'adjective',
        errorPattern: 'I have car red',
        correctPattern: 'I have a red car',
        explanation: 'Adjectives come before nouns in English',
      ),
      threatScore: 70.0,
      isNovelty: true,
    ),
    SniperRound(
      trap: L1Trap(
        id: 'ru_2',
        l1Source: L1Source.russian,
        category: ErrorCategory.tense,
        context: 'present',
        errorPattern: 'I am work here',
        correctPattern: 'I work here',
        explanation: 'Use Present Simple for permanent situations',
      ),
      threatScore: 65.0,
      isNovelty: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadGame() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _gameState = SniperGameState(
        currentBatch: _demoRounds,
        currentIndex: 0,
        timeLeftPercent: 1.0,
        coverIntegrity: 100,
      );
      _isLoading = false;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: SniperConfig.timerTickMs),
      (timer) {
        if (_gameState.isGameFinished) {
          timer.cancel();
          return;
        }

        final tickDecrement = SniperConfig.timerTickMs /
            (SniperConfig.missionTimeSeconds * 1000);

        setState(() {
          final newTime =
              (_gameState.timeLeftPercent - tickDecrement).clamp(0.0, 1.0);
          _gameState = _gameState.copyWith(
            timeLeftPercent: newTime,
            isOvertime: newTime <= 0 || _gameState.isOvertime,
          );
        });
      },
    );
  }

  void _submitAnswer(bool isError) {
    if (_selectedIsError != null) return;

    final currentRound = _gameState.currentRound;
    if (currentRound == null) return;

    // In demo: errorPattern != correctPattern means it's an error
    final actualIsError =
        currentRound.trap.errorPattern != currentRound.trap.correctPattern;
    final isCorrect = isError == actualIsError;

    setState(() {
      _selectedIsError = isError;

      if (isCorrect) {
        _gameState = _gameState.copyWith(
          totalCorrect: _gameState.totalCorrect + 1,
        );
      } else {
        final newCover =
            (_gameState.coverIntegrity - SniperConfig.coverPenaltyPerError)
                .clamp(0, 100);
        _gameState = _gameState.copyWith(
          totalWrong: _gameState.totalWrong + 1,
          coverIntegrity: newCover,
        );
      }
    });

    // Move to next question after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      _moveToNextQuestion();
    });
  }

  void _moveToNextQuestion() {
    if (_gameState.hasNextQuestion) {
      setState(() {
        _gameState = _gameState.copyWith(
          currentIndex: _gameState.currentIndex + 1,
        );
        _selectedIsError = null;
      });
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    _timer?.cancel();
    final rank = SniperRank.fromGameState(_gameState);
    final xp = (_gameState.totalCorrect * 10 * rank.xpMultiplier).toInt();

    setState(() {
      _gameState = _gameState.copyWith(
        isGameFinished: true,
        xpAwarded: xp,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sniper Mode')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_gameState.isGameFinished) {
      return _buildResultsScreen();
    }

    return _buildGameScreen();
  }

  Widget _buildGameScreen() {
    final currentRound = _gameState.currentRound;
    if (currentRound == null) {
      return const Scaffold(body: Center(child: Text('No rounds')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mission ${_gameState.currentIndex + 1}/${_gameState.currentBatch.length}',
        ),
        actions: [
          // Cover integrity indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildCoverIndicator(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timer bar
              _buildTimerBar(),
              const SizedBox(height: 16),

              // L1 Source badge
              _buildL1Badge(currentRound.trap.l1Source),
              const SizedBox(height: 24),

              // Sentence to analyze
              _buildSentenceCard(currentRound),
              const SizedBox(height: 24),

              // Answer buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Is this sentence correct?',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnswerButton(
                            label: '❌ Error',
                            isError: true,
                            currentRound: currentRound,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnswerButton(
                            label: '✅ Correct',
                            isError: false,
                            currentRound: currentRound,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Score display
              _buildScoreDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverIndicator() {
    final cover = _gameState.coverIntegrity;
    Color color;
    if (cover > 50) {
      color = Colors.green;
    } else if (cover > 25) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shield, color: color),
        const SizedBox(width: 4),
        Text(
          '$cover%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _gameState.isOvertime ? 'OVERTIME!' : 'Time',
              style: TextStyle(
                color: _gameState.isOvertime ? Colors.red : null,
                fontWeight:
                    _gameState.isOvertime ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              '${(_gameState.timeLeftPercent * SniperConfig.missionTimeSeconds).ceil()}s',
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: _gameState.timeLeftPercent,
          backgroundColor: Colors.grey[800],
          color: _gameState.isOvertime ? Colors.red : Colors.amber,
        ),
      ],
    );
  }

  Widget _buildL1Badge(L1Source source) {
    final (emoji, name) = switch (source) {
      L1Source.hebrew => ('🇮🇱', 'Hebrew'),
      L1Source.russian => ('🇷🇺', 'Russian'),
      L1Source.arabic => ('🇸🇦', 'Arabic'),
    };

    return Chip(
      avatar: Text(emoji),
      label: Text('$name interference pattern'),
      backgroundColor: Colors.grey[800],
    );
  }

  Widget _buildSentenceCard(SniperRound round) {
    // Randomly show error or correct pattern
    final showError = round.trap.errorPattern != round.trap.correctPattern;
    final sentence = showError ? round.trap.errorPattern : round.trap.correctPattern;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              '"$sentence"',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (_selectedIsError != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                round.trap.explanation,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (showError) ...[
                const SizedBox(height: 8),
                Text(
                  'Correct: "${round.trap.correctPattern}"',
                  style: TextStyle(color: Colors.green[400]),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton({
    required String label,
    required bool isError,
    required SniperRound currentRound,
  }) {
    final bool isSelected = _selectedIsError == isError;
    final actualIsError =
        currentRound.trap.errorPattern != currentRound.trap.correctPattern;
    final bool? isCorrect =
        _selectedIsError != null ? (isError == actualIsError) : null;

    Color? backgroundColor;
    Color? borderColor;

    if (_selectedIsError != null) {
      if (isError == actualIsError) {
        // This is the correct answer
        backgroundColor = Colors.green.withAlpha(76);
        borderColor = Colors.green;
      } else if (isSelected) {
        // User selected this but it's wrong
        backgroundColor = Colors.red.withAlpha(76);
        borderColor = Colors.red;
      }
    }

    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _selectedIsError == null ? () => _submitAnswer(isError) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: borderColor != null ? BorderSide(color: borderColor, width: 2) : null,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreItem('✅', '${_gameState.totalCorrect}', 'Correct'),
          _buildScoreItem('❌', '${_gameState.totalWrong}', 'Wrong'),
          _buildScoreItem('🛡️', '${_gameState.coverIntegrity}%', 'Cover'),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final rank = SniperRank.fromGameState(_gameState);

    return Scaffold(
      appBar: AppBar(title: const Text('Mission Complete')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rank.emoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              Text(
                rank.displayName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),

              // Stats card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'Cover Integrity',
                        '${_gameState.coverIntegrity}%',
                      ),
                      const Divider(),
                      _buildStatRow(
                        'Accuracy',
                        '${(_gameState.accuracy * 100).toInt()}%',
                      ),
                      const Divider(),
                      _buildStatRow('Correct', '${_gameState.totalCorrect}'),
                      const Divider(),
                      _buildStatRow('Wrong', '${_gameState.totalWrong}'),
                      const Divider(),
                      _buildStatRow(
                        'Time',
                        _gameState.isOvertime ? 'Overtime' : 'On time',
                      ),
                      const Divider(),
                      _buildStatRow('XP Earned', '+${_gameState.xpAwarded}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _gameState = const SniperGameState();
                        _selectedIsError = null;
                      });
                      _loadGame();
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('New Mission'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
