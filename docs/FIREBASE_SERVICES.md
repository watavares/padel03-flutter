# Firebase Services Documentation

## 🚀 Overview

Your Padel03 app now has a complete Firebase setup with Authentication, Firestore, and Analytics across multiple environments (dev/staging/prod).

## 🔥 Available Services

### 1. Authentication (`AuthService`)

Complete user authentication with email/password:

```dart
// Sign up
await AuthService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
);

// Sign in
await AuthService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await AuthService.signOut();

// Get current user
final user = AuthService.currentUser;

// Listen to auth state changes
AuthService.authStateChanges.listen((user) {
  // Handle user state change
});
```

### 2. Firestore Database (`FirestoreService`)

Environment-separated database operations:

```dart
// Create document
await FirestoreService.create('users', {
  'name': 'John Doe',
  'email': 'john@example.com',
});

// Read document
final doc = await FirestoreService.read('users', userId);

// Update document
await FirestoreService.update('users', userId, {
  'lastActive': DateTime.now(),
});

// Stream document changes
FirestoreService.streamDocument('users', userId).listen((doc) {
  // Handle document changes
});

// Padel-specific collections
final court = await FirestoreService.courts.add({
  'name': 'Court 1',
  'location': 'Madrid',
});
```

### 3. Analytics (`AnalyticsService`)

Track user behavior and app usage:

```dart
// Set user ID
await AnalyticsService.setUserId(user.uid);

// Log custom events
await AnalyticsService.logEvent(
  name: 'court_booking',
  parameters: {'court_id': 'court_123'},
);

// Padel-specific events
await AnalyticsService.logCourtBooking(
  courtId: 'court_123',
  courtName: 'Court 1',
  bookingDate: DateTime.now(),
  price: 25.0,
);

await AnalyticsService.logMatchCreated(
  matchId: 'match_456',
  matchType: 'doubles',
  playersCount: 4,
);
```

## 🛠️ Service Manager

Centralized service initialization:

```dart
// Initialize all services
await ServiceManager.initialize();

// Check initialization status
final isReady = ServiceManager.isInitialized;

// Get service status for debugging
final status = ServiceManager.getServiceStatus();
```

## 📱 Environment Configuration

Each environment has separate:
- Firebase projects
- Database collections (prefixed with environment)
- Analytics settings
- Configuration values

```dart
// Current environment info
final env = AppConfig.environment; // dev, staging, prod
final dbPrefix = FirestoreService.environmentPrefix; // "dev_", "staging_", "prod_"
```

## 🔒 Security Features

### Firestore Rules (to be configured in Firebase Console)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Environment-specific collections
    match /{environment}_{collection}/{document} {
      // Users can only access their own data
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.userId;
    }
    
    // Public read access for courts and tournaments
    match /{environment}_courts/{courtId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && get(/databases/$(database)/documents/$(environment)_users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Authentication Rules

```javascript
// Firebase Auth settings (configure in Firebase Console)
- Email verification required
- Password strength: minimum 6 characters
- Account enumeration protection enabled
- Multi-factor authentication (optional)
```

## 📊 Analytics Events

### Built-in Events
- `app_start` - App initialization
- `login` - User authentication
- `sign_up` - User registration
- `screen_view` - Page navigation

### Custom Padel Events
- `court_booking` - Court reservations
- `match_created` - Match setup
- `match_completed` - Match results
- `tournament_joined` - Tournament participation
- `user_search` - Search usage
- `app_rating` - User feedback

## 🚀 Quick Start

1. **Run the app:**
   ```bash
   flutter run -t lib/main_dev.dart -d chrome
   ```

2. **Test authentication:**
   - Click "Try Firebase Auth" button
   - Sign up with test email
   - Check Firebase Console for user creation

3. **Verify Firestore:**
   - Check Firebase Console > Firestore
   - Look for `dev_users` collection

4. **Check Analytics:**
   - Firebase Console > Analytics > Events
   - See `app_start` and custom events

## 🔍 Debugging

### Service Status
```dart
final status = ServiceManager.getServiceStatus();
print(status); // Comprehensive service information
```

### Analytics Debug
```dart
final analyticsInfo = AnalyticsService.getDebugInfo();
print(analyticsInfo); // Analytics configuration
```

### Environment Info
```dart
print('Environment: ${AppConfig.environment.name}');
print('Firebase initialized: ${ServiceManager.isInitialized}');
print('Analytics enabled: ${AppConfig.enableAnalytics}');
```

## 📚 Next Steps

1. **Configure Firestore Security Rules** in Firebase Console
2. **Set up Authentication providers** (Google, Apple, etc.)
3. **Configure Analytics audiences** and conversion events
4. **Add Firebase Storage** for file uploads
5. **Implement push notifications** with FCM
6. **Set up Firebase Hosting** for web deployment

## 🔗 Firebase Console Links

- **Development**: https://console.firebase.google.com/project/padel03-dev
- **Staging**: https://console.firebase.google.com/project/padel03-staging  
- **Production**: https://console.firebase.google.com/project/padel03-prod

## ⚠️ Important Notes

- **Environment Separation**: Each environment uses separate Firebase projects and database collections
- **Analytics**: Disabled in development, enabled in staging/production
- **Security**: Configure Firestore rules before deploying to production
- **Testing**: Use development environment for all testing

Your Firebase setup is now complete and ready for building your Padel app! 🏓