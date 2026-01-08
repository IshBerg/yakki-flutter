/// Intel Reader Screen - Reading comprehension mode
///
/// Features:
/// - Text reading with comprehension questions
/// - Vocabulary highlighting
/// - Teacher mode for creating content
///
/// Port of IntelReaderComponent.kt from yakkiedu.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class IntelReaderScreen extends StatefulWidget {
  final bool isTeacherMode;

  const IntelReaderScreen({
    super.key,
    this.isTeacherMode = false,
  });

  @override
  State<IntelReaderScreen> createState() => _IntelReaderScreenState();
}

class _IntelReaderScreenState extends State<IntelReaderScreen> {
  int _currentTextIndex = 0;
  bool _showQuestions = false;
  int _selectedAnswer = -1;

  // Demo reading texts
  final List<ReadingText> _texts = [
    ReadingText(
      title: 'The Morning Routine',
      level: 'A1',
      content: '''
Every morning, Anna wakes up at 7 o'clock. She gets out of bed and goes to the bathroom. She brushes her teeth and washes her face.

Then Anna goes to the kitchen. She makes breakfast - usually toast with butter and a cup of tea. She likes to read the news on her phone while eating.

At 8 o'clock, Anna leaves home and walks to the bus stop. The bus takes her to work. Her day begins!
''',
      questions: [
        ReadingQuestion(
          question: 'What time does Anna wake up?',
          options: ['6 o\'clock', '7 o\'clock', '8 o\'clock', '9 o\'clock'],
          correctAnswer: 1,
        ),
        ReadingQuestion(
          question: 'What does Anna have for breakfast?',
          options: [
            'Coffee and eggs',
            'Toast and tea',
            'Cereal and milk',
            'Nothing'
          ],
          correctAnswer: 1,
        ),
        ReadingQuestion(
          question: 'How does Anna get to work?',
          options: ['By car', 'By train', 'By bus', 'On foot'],
          correctAnswer: 2,
        ),
      ],
      vocabulary: ['routine', 'breakfast', 'usually'],
    ),
    ReadingText(
      title: 'My Best Friend',
      level: 'A2',
      content: '''
I want to tell you about my best friend, Tom. We have been friends since primary school. Tom is tall with brown hair and green eyes.

Tom is very funny and always makes me laugh. He loves sports, especially basketball. Every weekend, we play basketball together in the park.

Tom also likes music. He plays the guitar very well. Sometimes he writes his own songs. I think he is very talented.
''',
      questions: [
        ReadingQuestion(
          question: 'How long have they been friends?',
          options: [
            'Since high school',
            'Since university',
            'Since primary school',
            'Since last year'
          ],
          correctAnswer: 2,
        ),
        ReadingQuestion(
          question: 'What sport does Tom like?',
          options: ['Football', 'Basketball', 'Tennis', 'Swimming'],
          correctAnswer: 1,
        ),
        ReadingQuestion(
          question: 'What instrument does Tom play?',
          options: ['Piano', 'Drums', 'Violin', 'Guitar'],
          correctAnswer: 3,
        ),
      ],
      vocabulary: ['talented', 'especially', 'weekend'],
    ),
  ];

  void _checkAnswer() {
    final currentQuestion =
        _texts[_currentTextIndex].questions[_selectedAnswer];
    // Show result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedAnswer == currentQuestion.correctAnswer
              ? 'Correct!'
              : 'Try again!',
        ),
        backgroundColor: _selectedAnswer == currentQuestion.correctAnswer
            ? AppColors.accentGreen
            : AppColors.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTeacherMode) {
      return _buildTeacherMode();
    }

    return _buildReaderMode();
  }

  Widget _buildReaderMode() {
    final text = _texts[_currentTextIndex];

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      text.level,
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text.title,
                      style: const TextStyle(
                        color: AppColors.offWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _showQuestions
                    ? _buildQuestions(text)
                    : _buildReadingContent(text),
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _currentTextIndex > 0
                        ? () {
                            setState(() {
                              _currentTextIndex--;
                              _showQuestions = false;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slateGray,
                    ),
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showQuestions = !_showQuestions;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple,
                    ),
                    child: Text(_showQuestions ? 'Read Text' : 'Questions'),
                  ),
                  ElevatedButton(
                    onPressed: _currentTextIndex < _texts.length - 1
                        ? () {
                            setState(() {
                              _currentTextIndex++;
                              _showQuestions = false;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingContent(ReadingText text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text content
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.midnightBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text.content,
            style: const TextStyle(
              color: AppColors.offWhite,
              fontSize: 18,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Vocabulary section
        const Text(
          'Key Vocabulary',
          style: TextStyle(
            color: AppColors.accentGold,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: text.vocabulary.map((word) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentBlue),
              ),
              child: Text(
                word,
                style: const TextStyle(
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuestions(ReadingText text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comprehension Questions',
          style: TextStyle(
            color: AppColors.accentGold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...text.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.midnightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${question.question}',
                  style: const TextStyle(
                    color: AppColors.offWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...question.options.asMap().entries.map((optEntry) {
                  final optIndex = optEntry.key;
                  final option = optEntry.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAnswer = optIndex;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedAnswer == optIndex
                            ? AppColors.accentBlue.withAlpha(51)
                            : AppColors.slateGray.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedAnswer == optIndex
                              ? AppColors.accentBlue
                              : AppColors.slateGray,
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: _selectedAnswer == optIndex
                              ? AppColors.accentBlue
                              : AppColors.offWhite,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTeacherMode() {
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
                'Teacher Mode',
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create reading materials',
                style: TextStyle(
                  color: AppColors.steelBlue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: AppColors.midnightBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildTeacherOption(
                      icon: Icons.add_circle,
                      title: 'Create New Text',
                      subtitle: 'Add reading material',
                      onTap: () {},
                    ),
                    const Divider(color: AppColors.slateGray),
                    _buildTeacherOption(
                      icon: Icons.people,
                      title: 'Manage Students',
                      subtitle: 'View progress',
                      onTap: () {},
                    ),
                    const Divider(color: AppColors.slateGray),
                    _buildTeacherOption(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      subtitle: 'View statistics',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentCyan),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.offWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.steelBlue),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.steelBlue),
      onTap: onTap,
    );
  }
}

class ReadingText {
  final String title;
  final String level;
  final String content;
  final List<ReadingQuestion> questions;
  final List<String> vocabulary;

  ReadingText({
    required this.title,
    required this.level,
    required this.content,
    required this.questions,
    required this.vocabulary,
  });
}

class ReadingQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  ReadingQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}
