/// Detective Screen - Sentence Analysis game
///
/// Features:
/// - Parts of speech identification
/// - Sentence structure analysis
/// - Color-coded highlighting
///
/// Port of DetectiveSpectrumOverlay.kt from yakkiedu.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DetectiveScreen extends StatefulWidget {
  const DetectiveScreen({super.key});

  @override
  State<DetectiveScreen> createState() => _DetectiveScreenState();
}

class _DetectiveScreenState extends State<DetectiveScreen> {
  bool _isGameStarted = false;
  String _selectedMode = 'colors'; // colors, lines, full
  int _currentSentenceIndex = 0;

  final List<AnalysisSentence> _sentences = [
    AnalysisSentence(
      text: 'The quick brown fox jumps over the lazy dog',
      words: [
        WordAnalysis('The', 'determiner', 'subject'),
        WordAnalysis('quick', 'adjective', 'subject'),
        WordAnalysis('brown', 'adjective', 'subject'),
        WordAnalysis('fox', 'noun', 'subject'),
        WordAnalysis('jumps', 'verb', 'predicate'),
        WordAnalysis('over', 'preposition', 'predicate'),
        WordAnalysis('the', 'determiner', 'object'),
        WordAnalysis('lazy', 'adjective', 'object'),
        WordAnalysis('dog', 'noun', 'object'),
      ],
    ),
    AnalysisSentence(
      text: 'She is reading a very interesting book',
      words: [
        WordAnalysis('She', 'pronoun', 'subject'),
        WordAnalysis('is', 'verb', 'predicate'),
        WordAnalysis('reading', 'verb', 'predicate'),
        WordAnalysis('a', 'determiner', 'object'),
        WordAnalysis('very', 'adverb', 'object'),
        WordAnalysis('interesting', 'adjective', 'object'),
        WordAnalysis('book', 'noun', 'object'),
      ],
    ),
  ];

  List<int> _selectedWords = [];
  String? _targetPOS; // Part of speech to find

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _currentSentenceIndex = 0;
      _selectedWords = [];
      _targetPOS = 'noun'; // Start with finding nouns
    });
  }

  Color _getPOSColor(String pos) {
    switch (pos.toLowerCase()) {
      case 'noun':
        return AppColors.accentBlue;
      case 'verb':
        return AppColors.accentRed;
      case 'adjective':
        return AppColors.accentGreen;
      case 'adverb':
        return AppColors.accentPurple;
      case 'pronoun':
        return AppColors.accentOrange;
      case 'determiner':
        return AppColors.accentCyan;
      case 'preposition':
        return AppColors.accentTeal;
      default:
        return AppColors.steelBlue;
    }
  }

  void _selectWord(int index) {
    setState(() {
      if (_selectedWords.contains(index)) {
        _selectedWords.remove(index);
      } else {
        _selectedWords.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isGameStarted) {
      return _buildSetupScreen();
    }

    return _buildGameScreen();
  }

  Widget _buildSetupScreen() {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                'Inspector',
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sentence Analysis',
                style: TextStyle(
                  color: AppColors.steelBlue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Mode selection
              const Text(
                'Analysis Mode',
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  ('colors', 'Colors', 'Parts of Speech'),
                  ('lines', 'Lines', 'Sentence Structure'),
                  ('full', 'Full', 'Both Combined'),
                ].map((item) {
                  final isSelected = _selectedMode == item.$1;
                  return ChoiceChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.$2),
                        Text(
                          item.$3,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedMode = item.$1;
                      });
                    },
                    selectedColor: AppColors.accentPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.offWhite,
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
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'START',
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
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final sentence = _sentences[_currentSentenceIndex];

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Target instruction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getPOSColor(_targetPOS!).withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPOSColor(_targetPOS!),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Find all ',
                      style: TextStyle(
                        color: AppColors.offWhite,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _targetPOS!.toUpperCase(),
                      style: TextStyle(
                        color: _getPOSColor(_targetPOS!),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' words',
                      style: TextStyle(
                        color: AppColors.offWhite,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Legend
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'noun',
                  'verb',
                  'adjective',
                  'adverb',
                  'pronoun',
                ].map((pos) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPOSColor(pos).withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pos,
                      style: TextStyle(
                        color: _getPOSColor(pos),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Sentence words
              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: sentence.words.asMap().entries.map((entry) {
                      final index = entry.key;
                      final word = entry.value;
                      final isSelected = _selectedWords.contains(index);
                      final isCorrectTarget =
                          word.partOfSpeech.toLowerCase() ==
                              _targetPOS?.toLowerCase();

                      return GestureDetector(
                        onTap: () => _selectWord(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getPOSColor(word.partOfSpeech).withAlpha(128)
                                : AppColors.midnightBlue,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _getPOSColor(word.partOfSpeech)
                                  : AppColors.slateGray,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _getPOSColor(word.partOfSpeech)
                                          .withAlpha(77),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            word.text,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.offWhite,
                              fontSize: 20,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Check button
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Verify selection
                    final correctWords = sentence.words
                        .asMap()
                        .entries
                        .where((e) =>
                            e.value.partOfSpeech.toLowerCase() ==
                            _targetPOS?.toLowerCase())
                        .map((e) => e.key)
                        .toSet();
                    final selectedSet = _selectedWords.toSet();
                    final isCorrect = correctWords.containsAll(selectedSet) &&
                        selectedSet.containsAll(correctWords);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isCorrect
                              ? 'Correct! Well done!'
                              : 'Not quite right. Try again!',
                        ),
                        backgroundColor:
                            isCorrect ? AppColors.accentGreen : AppColors.errorRed,
                      ),
                    );

                    if (isCorrect) {
                      // Move to next target or sentence
                      setState(() {
                        _selectedWords = [];
                        if (_targetPOS == 'noun') {
                          _targetPOS = 'verb';
                        } else if (_targetPOS == 'verb') {
                          _targetPOS = 'adjective';
                        } else {
                          _currentSentenceIndex =
                              (_currentSentenceIndex + 1) % _sentences.length;
                          _targetPOS = 'noun';
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CHECK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnalysisSentence {
  final String text;
  final List<WordAnalysis> words;

  AnalysisSentence({required this.text, required this.words});
}

class WordAnalysis {
  final String text;
  final String partOfSpeech;
  final String sentenceRole;

  WordAnalysis(this.text, this.partOfSpeech, this.sentenceRole);
}
