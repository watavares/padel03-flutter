import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'analytics_providers.dart';

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Auth state stream provider - tracks Firebase Auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Current user provider - gets the current Firebase user
final currentFirebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// User document provider - fetches UserModel from Firestore
final userDocumentProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return UserService.getUserStream(uid);
});

/// Current user document provider - combines auth and Firestore data
final currentUserProvider = Provider<AsyncValue<UserModel?>>((ref) {
  final firebaseUser = ref.watch(currentFirebaseUserProvider);
  
  if (firebaseUser == null) {
    return const AsyncValue.data(null);
  }
  
  return ref.watch(userDocumentProvider(firebaseUser.uid));
});

/// Auth state notifier for handling authentication actions
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

/// Authentication state
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSigningOut;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isSigningOut = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSigningOut,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSigningOut: isSigningOut ?? this.isSigningOut,
    );
  }
}

/// Authentication controller
class AuthController extends StateNotifier<AuthState> {
  final Ref ref;

  AuthController(this.ref) : super(const AuthState());

  /// Get analytics controller
  AnalyticsController get _analytics => ref.read(analyticsControllerProvider);

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      _analytics.trackSignInAttempt('email');
      final credential = await AuthService.signInWithEmail(email: email, password: password);
      
      if (credential.user != null) {
        // Check if user document exists, create if not
        final existingUser = await UserService.getUser(credential.user!.uid);
        
        if (existingUser == null) {
          // Create user document if it doesn't exist
          final user = UserModel.newUser(
            uid: credential.user!.uid,
            email: credential.user!.email!,
            displayName: credential.user!.displayName ?? email.split('@')[0],
          );
          
          await UserService.createUser(user);
          print('✅ Created missing user document for ${credential.user!.email}');
        }
        
        final user = ref.read(currentUserProvider).value;
        if (user != null) {
          _analytics.trackSignInSuccess('email', user.uid);
        }
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _analytics.trackSignInFailure('email', e.toString());
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Register with email and password
  Future<void> registerWithEmail(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      _analytics.trackRegisterAttempt('email');
      final credential = await AuthService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (credential.user != null) {
        // Create user document
        final user = UserModel.newUser(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
        );
        
        await UserService.createUser(user);
        _analytics.trackRegisterSuccess('email', credential.user!.uid);
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _analytics.trackRegisterFailure('email', e.toString());
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final credential = await AuthService.signInWithGoogle();
      
      if (credential.user != null) {
        // Check if user document exists, create if not
        final existingUser = await UserService.getUser(credential.user!.uid);
        
        if (existingUser == null) {
          final user = UserModel.newUser(
            uid: credential.user!.uid,
            email: credential.user!.email!,
            displayName: credential.user!.displayName,
            photoUrl: credential.user!.photoURL,
          );
          
          await UserService.createUser(user);
        }
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final credential = await AuthService.signInWithApple();
      
      if (credential.user != null) {
        // Check if user document exists, create if not
        final existingUser = await UserService.getUser(credential.user!.uid);
        
        if (existingUser == null) {
          final user = UserModel.newUser(
            uid: credential.user!.uid,
            email: credential.user!.email!,
            displayName: credential.user!.displayName,
            photoUrl: credential.user!.photoURL,
          );
          
          await UserService.createUser(user);
        }
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await AuthService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isSigningOut: true, error: null);
    
    try {
      await AuthService.signOut();
      state = state.copyWith(isSigningOut: false);
    } catch (e) {
      state = state.copyWith(
        isSigningOut: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update user skill
  Future<void> updateUserSkill(UserSkill skill) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await UserService.updateUserFields(user.uid, {
        'skill': skill.toJson(),
      });
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}