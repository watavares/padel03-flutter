# Padel03 Flutter App

A comprehensive Flutter application for Padel enthusiasts with multi-environment Firebase integration and authentication.

## 🏓 Features

- **Multi-Provider Authentication**: Email/Password, Google Sign-In, Apple Sign-In
- **Multi-Environment Support**: Development, Staging, and Production environments
- **Firebase Integration**: Authentication, Firestore, Analytics, Storage
- **Cross-Platform**: Web, iOS, Android, Windows, macOS, Linux
- **CI/CD Pipeline**: Automated testing and deployment

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.35.7 or later)
- Dart SDK (3.9.2 or later)
- Firebase CLI
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/[YOUR-USERNAME]/padel03-flutter.git
   cd padel03-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Development environment
   firebase use padel03-dev
   flutter run -t lib/main_dev.dart
   
   # Staging environment
   firebase use padel03-staging
   flutter run -t lib/main_staging.dart
   
   # Production environment
   firebase use padel03-prod
   flutter run -t lib/main_prod.dart
   ```

### Available Scripts

- `flutter run -t lib/main_dev.dart -d chrome` - Run development environment on web
- `flutter run -t lib/main_staging.dart -d chrome` - Run staging environment on web
- `flutter run -t lib/main_prod.dart -d chrome` - Run production environment on web
- `flutter test` - Run unit tests
- `flutter build web` - Build for web deployment

## 🏗️ Project Structure

```
lib/
├── firebase/
│   ├── firebase_config.dart           # Environment configuration
│   ├── firebase_service.dart          # Firebase initialization
│   ├── firebase_options_dev.dart      # Development Firebase options
│   ├── firebase_options_staging.dart  # Staging Firebase options
│   └── firebase_options_prod.dart     # Production Firebase options
├── services/
│   ├── auth_service.dart              # Authentication service
│   ├── firestore_service.dart         # Firestore database service
│   ├── analytics_service.dart         # Analytics service
│   └── service_manager.dart           # Service coordination
├── pages/
│   └── auth_demo_page.dart            # Authentication demo UI
├── main_dev.dart                      # Development entry point
├── main_staging.dart                  # Staging entry point
└── main_prod.dart                     # Production entry point
```

## 🔒 Authentication

### Supported Providers

- **Email/Password**: Traditional email authentication
- **Google Sign-In**: OAuth with Google accounts
- **Apple Sign-In**: OAuth with Apple ID (iOS/macOS)

### Configuration

1. **Firebase Console**: Enable authentication providers
2. **Google OAuth**: Configure client IDs for web platform
3. **Apple Developer**: Set up Sign in with Apple capability

## 🌍 Multi-Environment Setup

### Firebase Projects

- **Development**: `padel03-dev` - For development and testing
- **Staging**: `padel03-staging` - For pre-production testing
- **Production**: `padel03-prod` - For live application

### Environment Variables

Each environment has its own Firebase configuration and can be extended with environment-specific variables.

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🚀 Deployment

### Web Deployment

```bash
# Build for production
flutter build web --dart-define=ENVIRONMENT=prod

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Mobile Deployment

```bash
# Android
flutter build apk --release --dart-define=ENVIRONMENT=prod
flutter build appbundle --release --dart-define=ENVIRONMENT=prod

# iOS
flutter build ios --release --dart-define=ENVIRONMENT=prod
```

## 🔧 CI/CD Pipeline

Automated workflows using GitHub Actions:

- **Code Quality**: Linting and formatting checks
- **Testing**: Automated unit and integration tests
- **Building**: Multi-platform builds
- **Deployment**: Automated deployment to Firebase

## 📱 Platform Support

- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Windows (Windows 10+)
- ✅ macOS (macOS 10.14+)
- ✅ Linux (Ubuntu 18.04+)

## 🛠️ Development

### Code Style

This project follows Flutter's official style guide and uses:

- `dart format` for code formatting
- `dart analyze` for static analysis
- `flutter test` for testing

### Git Workflow

1. Create feature branch from `develop`
2. Make changes and commit
3. Create Pull Request to `develop`
4. After review, merge to `develop`
5. Release branches are created from `develop` and merged to `main`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support, email [your-email@example.com] or create an issue in the GitHub repository.

---

**Built with ❤️ using Flutter and Firebase**
