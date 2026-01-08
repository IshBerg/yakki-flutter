/// Memory Screen - Word-Translation matching game
///
/// Features:
/// - Card flip animation
/// - Word-translation pairs matching
/// - Timer and scoring
/// - Different difficulty levels
///
/// Port of MemoryGameScreen.kt from yakkiedu.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  List<MemoryCard> _cards = [];
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  int _matchedPairs = 0;
  int _moves = 0;
  bool _isProcessing = false;
  bool _isGameFinished = false;
  bool _isGameStarted = false;
  int _gridSize = 4; // 4x4 grid = 8 pairs
  Timer? _gameTimer;
  int _elapsedSeconds = 0;

  // Demo word pairs
  final List<WordPair> _wordPairs = [
    WordPair('Hello', 'Привет'),
    WordPair('World', 'Мир'),
    WordPair('Book', 'Книга'),
    WordPair('Cat', 'Кот'),
    WordPair('Dog', 'Собака'),
    WordPair('House', 'Дом'),
    WordPair('Tree', 'Дерево'),
    WordPair('Water', 'Вода'),
    WordPair('Fire', 'Огонь'),
    WordPair('Sun', 'Солнце'),
    WordPair('Moon', 'Луна'),
    WordPair('Star', 'Звезда'),
  ];

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    final pairsNeeded = (_gridSize * _gridSize) ~/ 2;
    final selectedPairs = _wordPairs.take(pairsNeeded).toList();

    // Create cards (word + translation for each pair)
    _cards = [];
    for (int i = 0; i < selectedPairs.length; i++) {
      _cards.add(MemoryCard(
        id: i * 2,
        pairId: i,
        text: selectedPairs[i].english,
        isEnglish: true,
      ));
      _cards.add(MemoryCard(
        id: i * 2 + 1,
        pairId: i,
        text: selectedPairs[i].translation,
        isEnglish: false,
      ));
    }

    // Shuffle cards
    _cards.shuffle(Random());

    setState(() {
      _isGameStarted = true;
      _isGameFinished = false;
      _matchedPairs = 0;
      _moves = 0;
      _elapsedSeconds = 0;
      _firstFlippedIndex = null;
      _secondFlippedIndex = null;
    });

    // Start timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _flipCard(int index) {
    if (_isProcessing) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFlipped) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _secondFlippedIndex = index;
      _moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isProcessing = true;

    final first = _cards[_firstFlippedIndex!];
    final second = _cards[_secondFlippedIndex!];

    if (first.pairId == second.pairId && first.isEnglish != second.isEnglish) {
      // Match found!
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _cards[_firstFlippedIndex!].isMatched = true;
          _cards[_secondFlippedIndex!].isMatched = true;
          _matchedPairs++;
          _firstFlippedIndex = null;
          _secondFlippedIndex = null;
          _isProcessing = false;

          // Check if game is finished
          if (_matchedPairs == _cards.length ~/ 2) {
            _isGameFinished = true;
            _gameTimer?.cancel();
          }
        });
      });
    } else {
      // No match - flip back
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _cards[_firstFlippedIndex!].isFlipped = false;
          _cards[_secondFlippedIndex!].isFlipped = false;
          _firstFlippedIndex = null;
          _secondFlippedIndex = null;
          _isProcessing = false;
        });
      });
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isGameStarted) {
      return _buildSetupScreen();
    }

    if (_isGameFinished) {
      return _buildResultScreen();
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
                'Secret Files',
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Memory Match Game',
                style: TextStyle(
                  color: AppColors.steelBlue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Grid size selection
              const Text(
                'Grid Size',
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [4, 6].map((size) {
                  final isSelected = _gridSize == size;
                  final pairs = (size * size) ~/ 2;
                  return ChoiceChip(
                    label: Text('${size}x$size ($pairs pairs)'),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _gridSize = size;
                      });
                    },
                    selectedColor: AppColors.accentBlue,
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
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'START MISSION',
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
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatChip(
                    '',
                    _formatTime(_elapsedSeconds),
                    AppColors.accentOrange,
                  ),
                  _buildStatChip(
                    '',
                    '$_moves',
                    AppColors.accentBlue,
                  ),
                  _buildStatChip(
                    '',
                    '$_matchedPairs/${_cards.length ~/ 2}',
                    AppColors.accentGreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Game grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    return _buildCard(_cards[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String emoji, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(MemoryCard card, int index) {
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isMatched
              ? AppColors.accentGreen.withAlpha(77)
              : card.isFlipped
                  ? (card.isEnglish ? AppColors.accentBlue : AppColors.accentOrange)
                  : AppColors.midnightBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched
                ? AppColors.accentGreen
                : card.isFlipped
                    ? (card.isEnglish
                        ? AppColors.accentBlue
                        : AppColors.accentOrange)
                    : AppColors.slateGray,
            width: 2,
          ),
          boxShadow: card.isFlipped
              ? [
                  BoxShadow(
                    color: (card.isEnglish
                            ? AppColors.accentBlue
                            : AppColors.accentOrange)
                        .withAlpha(77),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    card.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: card.isMatched
                          ? AppColors.accentGreen
                          : Colors.white,
                      fontSize: _gridSize > 4 ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  '?',
                  style: TextStyle(
                    color: AppColors.steelBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    // Calculate stars based on moves
    final perfectMoves = _cards.length ~/ 2;
    final stars = _moves <= perfectMoves
        ? 3
        : _moves <= perfectMoves * 1.5
            ? 2
            : 1;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: AppColors.accentGold,
                    size: 48,
                  );
                }),
              ),
              const SizedBox(height: 16),

              const Text(
                'Mission Complete!',
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.midnightBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildResultRow('Time', _formatTime(_elapsedSeconds)),
                    const SizedBox(height: 12),
                    _buildResultRow('Moves', '$_moves'),
                    const SizedBox(height: 12),
                    _buildResultRow('Pairs', '$_matchedPairs'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Play again button
              SizedBox(
                width: 200,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isGameStarted = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'NEW MISSION',
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

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.steelBlue,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.offWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class MemoryCard {
  final int id;
  final int pairId;
  final String text;
  final bool isEnglish;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.pairId,
    required this.text,
    required this.isEnglish,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class WordPair {
  final String english;
  final String translation;

  WordPair(this.english, this.translation);
}
