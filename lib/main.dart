/// Yakki Flutter - Cross-platform English Learning App
///
/// Main entry point for the Flutter application.
/// Uses Material 3 design with Yakki military-spy theme.
/// Full port of yakkiedu Kotlin project.

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/main_menu/main_menu_screen.dart';

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
      theme: AppTheme.darkTheme,
      home: const MainMenuScreen(),
    );
  }
}
