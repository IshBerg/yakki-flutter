/// Home Screen - Main menu with game mode selection
///
/// Displays available game modes:
/// - Cloze Drills (fill-in-the-blank)
/// - Scrambler (sentence building)
/// - Sniper (grammar combat)
/// - Dictionary (word lookup)

import 'package:flutter/material.dart';
import '../cloze/cloze_screen.dart';
import '../sniper/sniper_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YAKKI EDU'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              _buildWelcomeCard(context),
              const SizedBox(height: 24),

              // Game modes grid
              Expanded(
                child: _buildGameModesGrid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎖️ YAKKI CORE IS ALIVE!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFD700),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your mission, Agent.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModesGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildGameModeCard(
          context,
          emoji: '📝',
          title: 'Cloze Drills',
          subtitle: 'Fill the gaps',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClozeScreen()),
            );
          },
        ),
        _buildGameModeCard(
          context,
          emoji: '🔀',
          title: 'Scrambler',
          subtitle: 'Build sentences',
          onTap: () {
            _showComingSoon(context, 'Scrambler');
          },
        ),
        _buildGameModeCard(
          context,
          emoji: '🎯',
          title: 'Sniper',
          subtitle: 'L1 Interference',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SniperScreen()),
            );
          },
        ),
        _buildGameModeCard(
          context,
          emoji: '📖',
          title: 'Dictionary',
          subtitle: 'Word lookup',
          onTap: () {
            _showComingSoon(context, 'Dictionary');
          },
        ),
      ],
    );
  }

  Widget _buildGameModeCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
