# 🔥 URGENT: Firebase Authentication Configuration

## ⚠️ CURRENT STATUS
- ✅ Firebase projects created (dev/staging/prod)
- ✅ Firestore rules deployed
- ❌ **Authentication providers NOT enabled** (this is why sign-up fails)

## 🔧 IMMEDIATE STEPS REQUIRED

### Step 1: Enable Email/Password Authentication

**The Firebase Console is open in the browser tab**. Follow these steps:

1. **Click on "Email/Password"** in the providers list
2. **Enable the first toggle** ("Email/Password")
3. **Click "Save"**

### Step 2: Enable Google Sign-In

1. **Click on "Google"** in the providers list
2. **Enable the toggle**
3. **Enter project support email**: `andri.wt@gmail.com`
4. **Verify authorized domains include**:
   - `localhost`
   - `127.0.0.1`
5. **Click "Save"**

### Step 3: Test Authentication

After enabling the providers:

1. **In your running app**, click **"Simple Auth Test"** button
2. **Try sign-up** with:
   - Email: `test@example.com`
   - Password: `password123`
3. **Check for success message**

## 🎯 EXPECTED RESULTS

After configuration:
- ✅ Email sign-up should work
- ✅ User appears in Firebase Console > Authentication > Users
- ✅ User profile created in Firestore > dev_users collection
- ✅ Google Sign-In button becomes functional

## 🔍 TROUBLESHOOTING

### If Email Sign-Up Still Fails:
1. **Check browser console** for errors (F12 > Console)
2. **Verify authentication is enabled** in Firebase Console
3. **Check Firestore rules** are deployed (already done ✅)

### If Google Sign-In Fails:
1. **Verify Google provider is enabled**
2. **Check authorized domains** include localhost
3. **Ensure support email is set**

## 📱 QUICK TEST COMMANDS

After configuration, test with these in your app:

```dart
// Test email authentication
await AuthService.signUpWithEmail(
  email: 'test@example.com',
  password: 'password123',
  displayName: 'Test User',
);

// Test Google authentication (after enabling)
await AuthService.signInWithGoogle();
```

## 🚨 ACTION REQUIRED NOW

**Go to the Firebase Console browser tab and enable Email/Password authentication immediately!**

This is the missing piece that's preventing authentication from working.