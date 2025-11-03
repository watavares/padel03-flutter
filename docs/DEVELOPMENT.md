# Development Guide

## 🏗️ Development Environment Setup

### Prerequisites
- Flutter SDK 3.35.7+
- Dart SDK 3.9.2+
- Git
- VS Code (recommended) or Android Studio
- Firebase CLI
- Node.js (for Firebase CLI)

### Initial Setup
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/padel03-flutter.git
cd padel03-flutter

# Install dependencies
flutter pub get

# Check Flutter doctor
flutter doctor -v
```

### Firebase Setup
```bash
# Login to Firebase
firebase login

# Set up development environment
firebase use padel03-dev
firebase deploy --only firestore:rules

# Verify Firebase connection
flutter run -t lib/main_dev.dart -d chrome
```

## 🚀 Development Workflow

### Branch Strategy
- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/**: Feature development branches
- **hotfix/**: Critical bug fixes
- **release/**: Release preparation branches

### Creating a New Feature
```bash
# Start from develop branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name

# Make your changes
# ... code changes ...

# Run tests
flutter test

# Format code
dart format .

# Analyze code
dart analyze

# Commit changes
git add .
git commit -m "feat: add your feature description"

# Push to GitHub
git push origin feature/your-feature-name

# Create Pull Request on GitHub
```

### Running the App

#### Development Environment
```bash
# Web
flutter run -t lib/main_dev.dart -d chrome

# Android
flutter run -t lib/main_dev.dart -d android

# iOS
flutter run -t lib/main_dev.dart -d ios
```

#### Staging Environment
```bash
# Web
flutter run -t lib/main_staging.dart -d chrome

# Android
flutter run -t lib/main_staging.dart -d android

# iOS
flutter run -t lib/main_staging.dart -d ios
```

#### Production Environment
```bash
# Web
flutter run -t lib/main_prod.dart -d chrome

# Android
flutter run -t lib/main_prod.dart -d android

# iOS
flutter run -t lib/main_prod.dart -d ios
```

## 🧪 Testing

### Running Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/widget_test.dart

# With coverage
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart
```

### Writing Tests

#### Unit Tests
```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('should sign in with email and password', () async {
      // Test implementation
    });
  });
}
```

#### Widget Tests
```dart
// test/widgets/auth_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/pages/auth_demo_page.dart';

void main() {
  testWidgets('AuthDemoPage should display login form', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthDemoPage()));
    
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
```

## 🏗️ Build Process

### Web Build
```bash
# Development
flutter build web --target=lib/main_dev.dart --dart-define=ENVIRONMENT=dev

# Staging
flutter build web --target=lib/main_staging.dart --dart-define=ENVIRONMENT=staging

# Production
flutter build web --target=lib/main_prod.dart --dart-define=ENVIRONMENT=prod
```

### Mobile Build

#### Android
```bash
# Debug APK
flutter build apk --debug --target=lib/main_dev.dart --dart-define=ENVIRONMENT=dev

# Release APK
flutter build apk --release --target=lib/main_prod.dart --dart-define=ENVIRONMENT=prod

# App Bundle (for Play Store)
flutter build appbundle --release --target=lib/main_prod.dart --dart-define=ENVIRONMENT=prod
```

#### iOS
```bash
# Debug
flutter build ios --debug --target=lib/main_dev.dart --dart-define=ENVIRONMENT=dev

# Release
flutter build ios --release --target=lib/main_prod.dart --dart-define=ENVIRONMENT=prod
```

## 📂 Project Structure

```
lib/
├── config/                 # App configuration
├── firebase/              # Firebase configuration and services
├── services/              # Business logic services
├── pages/                 # UI pages/screens
├── widgets/              # Reusable UI components
├── utils/                # Utility functions
├── models/               # Data models
├── providers/            # State management
└── main_*.dart           # Environment entry points

test/
├── unit/                 # Unit tests
├── widget/               # Widget tests
├── integration/          # Integration tests
└── mocks/                # Mock objects

.github/
├── workflows/            # CI/CD workflows
├── ISSUE_TEMPLATE/       # Issue templates
└── pull_request_template.md
```

## 🎯 Code Standards

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` for formatting
- Use `dart analyze` for static analysis
- Keep line length under 80 characters when possible

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Private members**: `_leadingUnderscore`

### Documentation
```dart
/// Brief description of the class/function
/// 
/// Longer description if needed. This can span multiple lines
/// and include examples:
/// 
/// ```dart
/// final service = AuthService();
/// await service.signIn('email@example.com', 'password');
/// ```
class AuthService {
  /// Signs in a user with email and password
  /// 
  /// Returns the user credential if successful, throws an exception otherwise.
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

### Error Handling
```dart
// Good: Specific exception handling
try {
  await authService.signIn(email, password);
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      showError('No user found for that email.');
      break;
    case 'wrong-password':
      showError('Wrong password provided.');
      break;
    default:
      showError('Authentication failed: ${e.message}');
  }
} catch (e) {
  showError('An unexpected error occurred: $e');
}
```

## 🔧 Debugging

### VS Code Configuration
The project includes VS Code launch configurations in `.vscode/launch.json`:
- **Dev**: Runs development environment
- **Staging**: Runs staging environment  
- **Prod**: Runs production environment

### Firebase Debugging
```bash
# Check Firestore rules
firebase firestore:rules:test --project=padel03-dev

# View logs
firebase functions:log --project=padel03-dev

# Run emulator suite
firebase emulators:start --project=padel03-dev
```

### Flutter Debugging
```bash
# Enable web debugging
flutter run -d chrome --web-renderer canvaskit

# Enable verbose logging
flutter run --verbose

# Profile mode
flutter run --profile

# Release mode
flutter run --release
```

## 🚀 Deployment

### Manual Deployment
```bash
# Build for production
flutter build web --target=lib/main_prod.dart --dart-define=ENVIRONMENT=prod

# Deploy to Firebase
firebase use padel03-prod
firebase deploy --only hosting
```

### Automated Deployment
- Push to `main` branch triggers production deployment
- Push to `develop` branch triggers staging deployment
- Pull requests trigger build validation

## 📋 Troubleshooting

### Common Issues

1. **Flutter Doctor Issues**
   ```bash
   flutter doctor -v
   flutter clean
   flutter pub get
   ```

2. **Firebase Connection Issues**
   ```bash
   firebase login
   firebase projects:list
   firebase use padel03-dev
   ```

3. **Dependency Issues**
   ```bash
   flutter clean
   flutter pub cache repair
   flutter pub get
   ```

4. **Build Issues**
   ```bash
   flutter clean
   flutter pub get
   flutter build web --verbose
   ```

### Getting Help
- Check Flutter documentation: https://flutter.dev/docs
- Firebase documentation: https://firebase.google.com/docs
- Project issues: Create an issue on GitHub
- Discord/Slack: Join Flutter community channels

---

Happy coding! 🚀