/// Cloze Drills Screen - Fill-in-the-blank game mode
///
/// Features:
/// - Library selection
/// - Masked sentences with multiple choice
/// - Timer-based gameplay
/// - XP rewards

import 'package:flutter/material.dart';
import '../../models/cloze_models.dart';
import '../../services/yakki_core_service.dart';

class ClozeScreen extends StatefulWidget {
  const ClozeScreen({super.key});

  @override
  State<ClozeScreen> createState() => _ClozeScreenState();
}

class _ClozeScreenState extends State<ClozeScreen> {
  final YakkiCoreService _coreService = YakkiCoreService();

  ClozeGameState _gameState = ClozeGameState();
  bool _isLoading = true;
  String? _selectedAnswer;

  // Demo questions for testing
  final List<ClozeQuestion> _demoQuestions = [
    ClozeQuestion(
      id: 'demo_1',
      originalSentence: 'I went to the store yesterday.',
      maskedSentence: 'I ___ to the store yesterday.',
      correctAnswer: 'went',
      options: ['went', 'go', 'going', 'gone'],
    ),
    ClozeQuestion(
      id: 'demo_2',
      originalSentence: 'She does not like coffee.',
      maskedSentence: 'She ___ not like coffee.',
      correctAnswer: 'does',
      options: ['does', 'do', 'did', 'done'],
    ),
    ClozeQuestion(
      id: 'demo_3',
      originalSentence: 'They have been waiting for hours.',
      maskedSentence: 'They have ___ waiting for hours.',
      correctAnswer: 'been',
      options: ['been', 'being', 'be', 'was'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    setState(() => _isLoading = true);

    // Use demo data for now
    final drill = ClozeDrill(
      libraryId: 'demo',
      libraryName: 'Demo Library',
      libraryEmoji: '📝',
      cefrLevel: 'A2',
      questions: _demoQuestions,
    );

    setState(() {
      _gameState = ClozeGameState(
        currentDrill: drill,
        currentIndex: 0,
        timeLeftSeconds: 30,
      );
      _isLoading = false;
    });
  }

  void _submitAnswer(String answer) {
    if (_selectedAnswer != null) return; // Already answered

    setState(() {
      _selectedAnswer = answer;
    });

    final currentQuestion = _gameState.currentQuestion;
    if (currentQuestion == null) return;

    final isCorrect = answer.toLowerCase() == currentQuestion.correctAnswer.toLowerCase();

    // Update game state
    setState(() {
      if (isCorrect) {
        final newStreak = _gameState.streak + 1;
        _gameState = _gameState.copyWith(
          totalCorrect: _gameState.totalCorrect + 1,
          streak: newStreak,
          bestStreak: newStreak > _gameState.bestStreak ? newStreak : _gameState.bestStreak,
        );
      } else {
        _gameState = _gameState.copyWith(
          totalWrong: _gameState.totalWrong + 1,
          streak: 0,
        );
      }
    });

    // Delay then move to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      _moveToNextQuestion();
    });
  }

  void _moveToNextQuestion() {
    final drill = _gameState.currentDrill;
    if (drill == null) return;

    final nextIndex = _gameState.currentIndex + 1;

    if (nextIndex < drill.questions.length) {
      setState(() {
        _gameState = _gameState.copyWith(currentIndex: nextIndex);
        _selectedAnswer = null;
      });
    } else {
      // Game finished
      setState(() {
        _gameState = _gameState.copyWith(isGameFinished: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cloze Drills')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_gameState.isGameFinished) {
      return _buildResultsScreen();
    }

    return _buildGameScreen();
  }

  Widget _buildGameScreen() {
    final currentQuestion = _gameState.currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(body: Center(child: Text('No questions')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_gameState.currentIndex + 1}/${_gameState.currentDrill?.questions.length ?? 0}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 4),
                Text('${_gameState.streak}'),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: _gameState.progress,
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(height: 24),

              // Masked sentence
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    currentQuestion.maskedSentence,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Answer options
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: currentQuestion.options.map((option) {
                    return _buildOptionButton(option, currentQuestion.correctAnswer);
                  }).toList(),
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

  Widget _buildOptionButton(String option, String correctAnswer) {
    final bool isSelected = _selectedAnswer == option;
    final bool isCorrect = option.toLowerCase() == correctAnswer.toLowerCase();
    final bool showResult = _selectedAnswer != null;

    Color backgroundColor;
    Color borderColor;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.3);
        borderColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.3);
        borderColor = Colors.red;
      } else {
        backgroundColor = Colors.grey[800]!;
        borderColor = Colors.grey[600]!;
      }
    } else {
      backgroundColor = Colors.grey[800]!;
      borderColor = Colors.grey[600]!;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _selectedAnswer == null ? () => _submitAnswer(option) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              option,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
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
          _buildScoreItem('🔥', '${_gameState.bestStreak}', 'Best Streak'),
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
    final accuracy = _gameState.accuracy;
    final rank = ClozeRank.fromAccuracy(accuracy, _gameState.isOvertime);

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
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

              // Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildStatRow('Accuracy', '${(accuracy * 100).toInt()}%'),
                      const Divider(),
                      _buildStatRow('Correct', '${_gameState.totalCorrect}'),
                      const Divider(),
                      _buildStatRow('Wrong', '${_gameState.totalWrong}'),
                      const Divider(),
                      _buildStatRow('Best Streak', '${_gameState.bestStreak}'),
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
                        _gameState = ClozeGameState();
                        _selectedAnswer = null;
                      });
                      _loadGame();
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Play Again'),
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
