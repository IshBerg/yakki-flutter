/// Yakki Flutter - Cross-platform English Learning App
///
/// Main entry point for the Flutter application.
/// Uses Material 3 design with Yakki military-spy theme.

import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const YakkiApp());
}

/// Root application widget.
class YakkiApp extends StatelessWidget {
  const YakkiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yakki Edu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Yakki military theme - dark with gold accents
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700), // Gold
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        // Custom text theme
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
