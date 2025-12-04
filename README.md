# SCC Learning App

A comprehensive educational application for students, teachers, and parents built with Flutter.

## 🚀 Quick Start

### 1. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2. Configure Firebase
```bash
flutterfire configure
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

**📖 For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## ⚙️ Configuration Required

**IMPORTANT:** This app requires Firebase configuration to work fully. See [CONFIGURATION_SUMMARY.md](CONFIGURATION_SUMMARY.md) for what you need to configure.

### What You Need:
- ✅ Firebase project (free tier is fine)
- ✅ FlutterFire CLI installed
- ✅ Run `flutterfire configure`

### What You DON'T Need:
- ❌ No other API keys
- ❌ No payment gateways
- ❌ No third-party services

Everything is handled through Firebase!

## Features

### Student Features
- Take quizzes offline
- Review flashcards
- Earn points and unlock badges
- Track progress and achievements
- Maintain learning streaks

### Teacher Features
- Create quiz questions manually
- Upload quiz questions via CSV/XLSX files
- Monitor student progress
- Validate quiz results with activity logging
- View class analytics

### Parent Features
- View child's progress
- Monitor learning activities

## Tech Stack

- **Framework**: Flutter 3.24+
- **Language**: Dart 3.5+
- **State Management**: Riverpod 2.5+
- **Local Database**: SQLite (sqflite)
- **Cloud Backend**: Firebase (Auth, Firestore, Storage, FCM, Analytics)
- **File Parsing**: CSV, Excel

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App configuration and routing
├── core/                     # Core functionality
│   ├── constants/           # App constants (colors, styles, routes)
│   ├── services/            # Business logic services
│   ├── utils/               # Utility functions
│   ├── errors/              # Error handling
│   └── widgets/             # Reusable widgets
├── data/                     # Data layer
│   ├── models/              # Data models
│   ├── repositories/        # Data repositories
│   └── local/               # Local database
└── features/                 # Feature modules
    ├── auth/                # Authentication
    ├── student/             # Student features
    ├── teacher/             # Teacher features
    ├── parent/              # Parent features
    ├── onboarding/          # Onboarding flow
    └── shared/              # Shared features
```

## Database Schema

The app uses SQLite for local storage with the following main tables:
- `users` - User accounts
- `quiz_questions` - Quiz questions
- `flashcards` - Flashcard content
- `student_progress` - Quiz results and progress
- `badges` - Achievement badges
- `user_badges` - User badge unlocks
- `assignments` - Teacher assignments
- `sync_queue` - Offline sync queue

## Key Features Implementation

### Offline-First Architecture
- All data is stored locally in SQLite
- Changes are queued for sync when online
- Automatic sync when connection is restored

### Quiz Validation
- Hash signatures for quiz results
- Activity logging (pauses, answer changes)
- Teacher validation dashboard
- Suspicious activity detection

### Points & Badges System
- Points awarded for correct answers
- Perfect score bonuses
- Streak tracking
- Automatic badge unlocking

## Documentation

- **[QUICK_START.md](QUICK_START.md)** - Fastest way to get started
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed setup instructions
- **[CONFIGURATION_SUMMARY.md](CONFIGURATION_SUMMARY.md)** - What needs to be configured
- **[CONFIGURATION_CHECKLIST.md](CONFIGURATION_CHECKLIST.md)** - Complete checklist

## Testing

Run tests with:
```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please contact the development team.
