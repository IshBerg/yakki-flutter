# Yakki Flutter

**Cross-platform Flutter app for Yakki Edu English learning platform.**

## Overview

Yakki Flutter is the multi-platform frontend for Yakki Edu, targeting:
- iOS
- Android
- Web
- Windows
- macOS
- Linux

## Project Structure

```
yakki_flutter/
├── lib/
│   ├── main.dart              # App entry point
│   ├── features/
│   │   ├── home/              # Main menu
│   │   │   └── home_screen.dart
│   │   └── cloze/             # Cloze Drills game
│   │       └── cloze_screen.dart
│   ├── models/
│   │   └── cloze_models.dart  # Data models (mirrors yakki-core)
│   └── services/
│       └── yakki_core_service.dart  # Platform channel bridge
├── android/                   # Android platform files
├── ios/                       # iOS platform files
├── web/                       # Web platform files
└── pubspec.yaml
```

## Features

### Implemented
- [x] Home screen with game mode selection
- [x] Cloze Drills game with demo questions
- [x] Dark military theme (Yakki style)
- [x] Score tracking and results screen
- [x] Yakki Core service (Platform Channels ready)

### Planned
- [ ] Platform Channel integration with yakki-core
- [ ] Scrambler mode
- [ ] Sniper mode
- [ ] Dictionary
- [ ] Settings screen
- [ ] User progress persistence
- [ ] Cloud sync

## Getting Started

### Prerequisites
- Flutter SDK 3.27+
- Dart 3.6+

### Run

```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for release
flutter build apk
flutter build ios
flutter build web
```

### Analyze

```bash
flutter analyze
```

## Architecture

### State Management
Currently using simple StatefulWidget. Will migrate to:
- Provider/Riverpod for state management
- Bloc for complex features

### Native Integration
Uses Platform Channels to communicate with native Kotlin code:

```dart
// Dart
final channel = MethodChannel('com.yakki.core/cloze');
final xp = await channel.invokeMethod('calculateClozeXP', {...});
```

```kotlin
// Kotlin (Android)
class YakkiCorePlugin : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "calculateClozeXP" -> {
                val xp = XPCalculator.calculateClozeXP(...)
                result.success(xp)
            }
        }
    }
}
```

## Theme

Yakki military-spy theme:
- Dark background
- Gold accents (#FFD700)
- Material 3 design
- Military terminology

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.1.0 | 2026-01-08 | Initial project setup with Cloze Drills |

## Related Projects

- **yakki-core** - Shared Kotlin business logic
- **yakkiedu** - Original Android app (Jetpack Compose)
