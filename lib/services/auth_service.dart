import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../config/app_config.dart';
import '../firebase/firebase_service.dart';

/// Authentication service handling Firebase Auth operations
class AuthService {
  static final FirebaseAuth _auth = FirebaseService.auth;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  /// Register with email and password
  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }

      // Send email verification
      await credential.user?.sendEmailVerification();

      await _analytics.logSignUp(signUpMethod: 'email');
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Sign up with email and password (alias for registerWithEmail)
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      await _analytics.logLogin(loginMethod: 'email');
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign in with Google
  static Future<UserCredential> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In...');
      late final GoogleSignInAccount? googleUser;
      
      if (kIsWeb) {
        // Web-specific Google Sign-In with popup
        final String webClientId = _getGoogleClientId();
        print('🔵 Using web client ID: $webClientId');
        
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          clientId: webClientId,
          signInOption: SignInOption.standard,
        );

        print('🔵 Calling googleSignIn.signIn()...');
        googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          print('❌ Google sign-in was cancelled by user');
          throw Exception('Google sign-in was cancelled');
        }
        print('✅ Google user obtained: ${googleUser.email}');
      } else {
        // Mobile Google Sign-In
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        
        googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google sign-in was cancelled');
        }
      }

      print('🔵 Getting Google authentication credentials...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        print('❌ Failed to get access token from Google');
        throw Exception('Failed to get access token from Google');
      }
      print('✅ Got Google auth credentials');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔵 Signing in with Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      await _analytics.logLogin(loginMethod: 'google');
      
      print('✅ Google Sign-In completed successfully');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      if (e.toString().contains('popup_closed')) {
        throw Exception('Sign-in was cancelled. Please try again.');
      } else if (e.toString().contains('access_denied')) {
        throw Exception('Access denied. Please check your permissions.');
      } else {
        throw Exception('Google sign in failed: $e');
      }
    }
  }

  /// Sign in with Apple (iOS/macOS only)
  static Future<UserCredential> signInWithApple() async {
    if (kIsWeb) {
      throw Exception('Apple Sign-In is not available on web');
    }

    try {
      final rawNonce = _generateNonce();
      final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Update display name if available from Apple
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
        }
      }

      await _analytics.logLogin(loginMethod: 'apple');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  // Generate a cryptographically secure random nonce
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  // Get Google OAuth Client ID based on environment
  static String _getGoogleClientId() {
    switch (AppConfig.environment) {
      case Environment.dev:
        return '703867063585-gb6532om5hk31uij4nr9jdscric9da89.apps.googleusercontent.com';
      case Environment.staging:
        return '717241670214-2s9ul6fafuf247esrc71csm33h8jg6tk.apps.googleusercontent.com';
      case Environment.prod:
        return '595593582051-YOUR_PROD_CLIENT_ID.apps.googleusercontent.com';
    }
  }

  /// Check if Apple Sign-In is available
  static Future<bool> isAppleSignInAvailable() async {
    if (kIsWeb) return false; // Apple Sign-In is not available on web
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      return false;
    }
  }

  /// Check if Google Sign-In is available
  static Future<bool> isGoogleSignInAvailable() async {
    try {
      return true; // Google Sign In is available on all platforms
    } catch (e) {
      return false;
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out from all providers
  static Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      await _auth.signOut();
      await _analytics.logEvent(name: 'logout');
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Delete user account
  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      await user.delete();
      await _analytics.logEvent(name: 'account_deleted');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user profile
  static Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName.trim());
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Check if email is verified
  static bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }

  /// Handle Firebase Auth exceptions and convert to user-friendly messages
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'credential-already-in-use':
        return 'This account is already linked to another user.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
    }
  }
}
