/// Dictionary Screen - User's saved words
///
/// Features:
/// - Word list with translations
/// - Search functionality
/// - Add/remove words
/// - Practice mode
///
/// Port of Dictionary feature from yakkiedu.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Demo words
  final List<DictionaryWord> _words = [
    DictionaryWord('Hello', 'Привет', 'Greeting', DateTime.now()),
    DictionaryWord('World', 'Мир', 'Noun', DateTime.now()),
    DictionaryWord('Book', 'Книга', 'Noun', DateTime.now()),
    DictionaryWord('Beautiful', 'Красивый', 'Adjective', DateTime.now()),
    DictionaryWord('Run', 'Бежать', 'Verb', DateTime.now()),
    DictionaryWord('Quickly', 'Быстро', 'Adverb', DateTime.now()),
    DictionaryWord('House', 'Дом', 'Noun', DateTime.now()),
    DictionaryWord('Friend', 'Друг', 'Noun', DateTime.now()),
  ];

  List<DictionaryWord> get _filteredWords {
    if (_searchQuery.isEmpty) return _words;
    return _words
        .where((w) =>
            w.english.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            w.translation.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        '',
                        style: TextStyle(fontSize: 32),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'My Dictionary',
                        style: TextStyle(
                          color: AppColors.offWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.midnightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.offWhite),
                      decoration: InputDecoration(
                        hintText: 'Search words...',
                        hintStyle: TextStyle(color: AppColors.steelBlue),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.steelBlue),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Word count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredWords.length} words',
                    style: const TextStyle(
                      color: AppColors.steelBlue,
                      fontSize: 14,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Sort options
                    },
                    icon: const Icon(
                      Icons.sort,
                      color: AppColors.accentBlue,
                      size: 18,
                    ),
                    label: const Text(
                      'Sort',
                      style: TextStyle(color: AppColors.accentBlue),
                    ),
                  ),
                ],
              ),
            ),

            // Word list
            Expanded(
              child: _filteredWords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No words yet'
                                : 'No words found',
                            style: const TextStyle(
                              color: AppColors.steelBlue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredWords.length,
                      itemBuilder: (context, index) {
                        final word = _filteredWords[index];
                        return _buildWordCard(word);
                      },
                    ),
            ),

            // Add word button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Show add word dialog
                    _showAddWordDialog();
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Word',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(DictionaryWord word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.midnightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          word.english,
          style: const TextStyle(
            color: AppColors.offWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word.translation,
              style: const TextStyle(
                color: AppColors.steelBlue,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.partOfSpeech,
                style: const TextStyle(
                  color: AppColors.accentPurple,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.volume_up,
                color: AppColors.accentBlue,
              ),
              onPressed: () {
                // Text-to-speech
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.errorRed,
              ),
              onPressed: () {
                // Delete word
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWordDialog() {
    final englishController = TextEditingController();
    final translationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.midnightBlue,
          title: const Text(
            'Add New Word',
            style: TextStyle(color: AppColors.offWhite),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: englishController,
                style: const TextStyle(color: AppColors.offWhite),
                decoration: const InputDecoration(
                  hintText: 'English word',
                  hintStyle: TextStyle(color: AppColors.steelBlue),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: translationController,
                style: const TextStyle(color: AppColors.offWhite),
                decoration: const InputDecoration(
                  hintText: 'Translation',
                  hintStyle: TextStyle(color: AppColors.steelBlue),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.steelBlue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (englishController.text.isNotEmpty &&
                    translationController.text.isNotEmpty) {
                  setState(() {
                    _words.add(DictionaryWord(
                      englishController.text,
                      translationController.text,
                      'Unknown',
                      DateTime.now(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DictionaryWord {
  final String english;
  final String translation;
  final String partOfSpeech;
  final DateTime addedAt;

  DictionaryWord(
    this.english,
    this.translation,
    this.partOfSpeech,
    this.addedAt,
  );
}
