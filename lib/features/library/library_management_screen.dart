/// Library Management Screen - Content packs toggle
///
/// Features:
/// - Enable/disable content libraries
/// - Download progress
/// - Library statistics
///
/// Port of LibraryManagementScreen.kt from yakkiedu.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LibraryManagementScreen extends StatefulWidget {
  const LibraryManagementScreen({super.key});

  @override
  State<LibraryManagementScreen> createState() =>
      _LibraryManagementScreenState();
}

class _LibraryManagementScreenState extends State<LibraryManagementScreen> {
  // Demo libraries
  final List<ContentLibrary> _libraries = [
    ContentLibrary(
      id: 'articles',
      name: 'Articles (a/an/the)',
      description: 'Definite and indefinite articles',
      unitCount: 25,
      isEnabled: true,
      category: 'Cloze Drills',
    ),
    ContentLibrary(
      id: 'prepositions',
      name: 'Prepositions',
      description: 'In, on, at, by, for, etc.',
      unitCount: 30,
      isEnabled: true,
      category: 'Cloze Drills',
    ),
    ContentLibrary(
      id: 'pronouns',
      name: 'Pronouns',
      description: 'Personal, possessive, reflexive',
      unitCount: 20,
      isEnabled: false,
      category: 'Cloze Drills',
    ),
    ContentLibrary(
      id: 'negatives',
      name: 'Negatives',
      description: 'No, not, never, nothing',
      unitCount: 15,
      isEnabled: false,
      category: 'Cloze Drills',
    ),
    ContentLibrary(
      id: 'questions',
      name: 'Questions',
      description: 'Wh-questions and auxiliaries',
      unitCount: 20,
      isEnabled: true,
      category: 'Cloze Drills',
    ),
    ContentLibrary(
      id: 'hebrew_l1',
      name: 'Hebrew L1 Errors',
      description: 'Common Hebrew interference patterns',
      unitCount: 50,
      isEnabled: true,
      category: 'Sniper Mode',
    ),
    ContentLibrary(
      id: 'russian_l1',
      name: 'Russian L1 Errors',
      description: 'Common Russian interference patterns',
      unitCount: 40,
      isEnabled: false,
      category: 'Sniper Mode',
    ),
    ContentLibrary(
      id: 'arabic_l1',
      name: 'Arabic L1 Errors',
      description: 'Common Arabic interference patterns',
      unitCount: 35,
      isEnabled: false,
      category: 'Sniper Mode',
    ),
  ];

  void _toggleLibrary(String id) {
    setState(() {
      final index = _libraries.indexWhere((l) => l.id == id);
      if (index != -1) {
        _libraries[index] = _libraries[index].copyWith(
          isEnabled: !_libraries[index].isEnabled,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group libraries by category
    final groupedLibraries = <String, List<ContentLibrary>>{};
    for (final lib in _libraries) {
      groupedLibraries.putIfAbsent(lib.category, () => []).add(lib);
    }

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
                  const Text(
                    '',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Libraries',
                          style: TextStyle(
                            color: AppColors.offWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Enable or disable content packs',
                          style: TextStyle(
                            color: AppColors.steelBlue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard(
                    'Total',
                    '${_libraries.length}',
                    AppColors.accentBlue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Enabled',
                    '${_libraries.where((l) => l.isEnabled).length}',
                    AppColors.accentGreen,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Units',
                    '${_libraries.where((l) => l.isEnabled).fold<int>(0, (sum, l) => sum + l.unitCount)}',
                    AppColors.accentGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Library list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedLibraries.length,
                itemBuilder: (context, index) {
                  final category = groupedLibraries.keys.elementAt(index);
                  final libraries = groupedLibraries[category]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      // Libraries in category
                      ...libraries.map((lib) => _buildLibraryCard(lib)),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withAlpha(179),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryCard(ContentLibrary lib) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.midnightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lib.isEnabled
              ? AppColors.accentGreen.withAlpha(128)
              : AppColors.slateGray.withAlpha(77),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          lib.name,
          style: TextStyle(
            color: lib.isEnabled ? AppColors.offWhite : AppColors.steelBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lib.description,
              style: TextStyle(
                color: lib.isEnabled
                    ? AppColors.steelBlue
                    : AppColors.steelBlue.withAlpha(128),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${lib.unitCount} units',
              style: TextStyle(
                color: lib.isEnabled
                    ? AppColors.accentGold
                    : AppColors.steelBlue.withAlpha(128),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: lib.isEnabled,
          onChanged: (_) => _toggleLibrary(lib.id),
          activeColor: AppColors.accentGreen,
        ),
      ),
    );
  }
}

class ContentLibrary {
  final String id;
  final String name;
  final String description;
  final int unitCount;
  final bool isEnabled;
  final String category;

  ContentLibrary({
    required this.id,
    required this.name,
    required this.description,
    required this.unitCount,
    required this.isEnabled,
    required this.category,
  });

  ContentLibrary copyWith({
    String? id,
    String? name,
    String? description,
    int? unitCount,
    bool? isEnabled,
    String? category,
  }) {
    return ContentLibrary(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitCount: unitCount ?? this.unitCount,
      isEnabled: isEnabled ?? this.isEnabled,
      category: category ?? this.category,
    );
  }
}
