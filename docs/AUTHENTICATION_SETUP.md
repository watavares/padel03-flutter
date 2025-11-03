# Firebase Authentication Configuration Guide

## 🔐 Enabling Authentication Providers

To enable Google and Apple sign-in, you need to configure them in each Firebase project.

### Google Sign-In Configuration

#### For Development Environment
1. Go to [Firebase Console - padel03-dev](https://console.firebase.google.com/project/padel03-dev)
2. Navigate to **Authentication** > **Sign-in method**
3. Click **Google** and enable it
4. For web apps, add your domain to authorized domains:
   - `localhost` (for development)
   - `127.0.0.1` (for development)
   - Your production domain (e.g., `padel03.com`)

#### For Staging Environment
1. Go to [Firebase Console - padel03-staging](https://console.firebase.google.com/project/padel03-staging)
2. Repeat the same steps as development

#### For Production Environment
1. Go to [Firebase Console - padel03-prod](https://console.firebase.google.com/project/padel03-prod)
2. Repeat the same steps as development

### Apple Sign-In Configuration

#### For Development Environment
1. Go to [Firebase Console - padel03-dev](https://console.firebase.google.com/project/padel03-dev)
2. Navigate to **Authentication** > **Sign-in method**
3. Click **Apple** and enable it
4. Configure your Apple Developer settings:
   - Service ID
   - Team ID
   - Key ID
   - Private Key

#### For Staging Environment
1. Go to [Firebase Console - padel03-staging](https://console.firebase.google.com/project/padel03-staging)
2. Repeat the same steps as development

#### For Production Environment
1. Go to [Firebase Console - padel03-prod](https://console.firebase.google.com/project/padel03-prod)
2. Repeat the same steps as development

### Email/Password Configuration

This is already enabled by default when you create a Firebase project with Authentication.

## 🧪 Testing Authentication

1. **Run your app:**
   ```bash
   flutter run -t lib/main_dev.dart -d chrome
   ```

2. **Click "Try Firebase Auth"**

3. **Test different sign-in methods:**
   - Email/Password (create new account)
   - Google Sign-In (if configured)
   - Apple Sign-In (if configured and on supported platform)

4. **Verify in Firebase Console:**
   - Check **Authentication** > **Users** tab
   - See newly created users
   - Check **Firestore Database** for user profiles in `dev_users` collection

## ⚠️ Important Notes

- **Google Sign-In** works on web, Android, and iOS
- **Apple Sign-In** is required for iOS apps and works on web with configuration
- **Email verification** is automatically sent for email/password sign-ups
- **User profiles** are automatically created in Firestore with additional metadata

## 🔧 Troubleshooting

### Common Issues

1. **Google Sign-In not working:**
   - Check if Google provider is enabled in Firebase Console
   - Verify authorized domains include your current domain

2. **Apple Sign-In not available:**
   - Apple Sign-In is primarily for iOS/macOS
   - Web support requires additional Apple Developer configuration

3. **Email sign-up failing:**
   - Check Firebase Console error logs
   - Verify email format
   - Check password requirements (minimum 6 characters)

4. **Firestore permission errors:**
   - Check Firestore security rules
   - Ensure user is authenticated before writing to database

### Debug Information

The app provides debug information about authentication providers:
- Check the Firebase Status Widget for connection status
- Use the ServiceManager.getServiceStatus() for detailed debug info

## 🚀 Next Steps

1. **Configure providers** in Firebase Console
2. **Test authentication** with different methods
3. **Set up proper security rules** for Firestore
4. **Add user profile management** features
5. **Implement password reset** functionality