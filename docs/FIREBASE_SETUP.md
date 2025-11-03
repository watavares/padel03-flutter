# Firebase Multi-Environment Setup Guide ✅ COMPLETE

## Overview
This project is configured to support multiple Firebase environments:
- **Development (dev)**: For local development and testing ✅
- **Staging**: For pre-production testing ✅
- **Production (prod)**: For live app ✅

## 🔥 Firebase Projects Setup ✅ COMPLETE

### ✅ Firebase Projects Created:
1. `padel03-dev` (Development) ✅
2. `padel03-staging` (Staging) ✅
3. `padel03-prod` (Production) ✅

### ✅ Configuration Complete:
All three environments have been configured with FlutterFire CLI and are ready to use!

## 🚀 Running Different Environments

### Using Scripts (Recommended)
```bash
# Development
./scripts/run_dev.bat     # Windows
./scripts/run_dev.sh      # Linux/Mac

# Staging
./scripts/run_staging.bat # Windows
./scripts/run_staging.sh  # Linux/Mac

# Production
./scripts/run_prod.bat    # Windows
./scripts/run_prod.sh     # Linux/Mac
```

### Using Flutter CLI
```bash
# Development
flutter run -t lib/main_dev.dart -d chrome

# Staging
flutter run -t lib/main_staging.dart -d chrome

# Production
flutter run -t lib/main_prod.dart -d chrome
```

### Using VS Code
Use the launch configurations in `.vscode/launch.json`:
- "flutter_padel03 (dev - chrome)"
- "flutter_padel03 (staging - chrome)"
- "flutter_padel03 (prod - chrome)"

## 📱 Platform-Specific Configuration

### Android
For Android builds, you'll need to:
1. Add `google-services.json` files for each environment
2. Configure build flavors in `android/app/build.gradle`

### iOS
For iOS builds, you'll need to:
1. Add `GoogleService-Info.plist` files for each environment
2. Configure schemes in Xcode

### Web
Web configuration is handled automatically through the Firebase options.

## 🛠️ Environment Configuration

Each environment has its own configuration in `lib/config/app_config.dart`:

- **App Name**: Different app names for each environment
- **Bundle ID**: Unique bundle identifiers
- **API URLs**: Different backend endpoints
- **Analytics**: Disabled in dev, enabled in staging/prod
- **Crashlytics**: Disabled in dev, enabled in staging/prod

## 📋 Next Steps

1. **Create Firebase Projects**: Set up the three Firebase projects
2. **Run FlutterFire CLI**: Configure each environment
3. **Update Firebase Config**: Copy the generated options
4. **Test Environments**: Run each environment to verify setup
5. **Configure Services**: Set up Authentication, Firestore, Storage, etc.

## 🔍 Troubleshooting

- Ensure FlutterFire CLI is installed: `dart pub global activate flutterfire_cli`
- Make sure you're logged into Firebase CLI: `firebase login`
- Verify project IDs match in Firebase Console
- Check that `firebase_options.dart` is generated correctly

## 📚 Firebase Services Available

- **Authentication**: `FirebaseService.auth`
- **Firestore**: `FirebaseService.firestore`
- **Storage**: `FirebaseService.storage`
- **Analytics**: `FirebaseService.analytics` (if enabled)

Example usage:
```dart
// Get current user
final user = FirebaseService.auth.currentUser;

// Access Firestore
final doc = await FirebaseService.firestore
    .collection('users')
    .doc(user?.uid)
    .get();
```