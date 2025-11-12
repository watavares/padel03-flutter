import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/firestore_service.dart';
import '../widgets/snack.dart';
import '../features/auth/welcome.dart';
import '../features/auth/login.dart';
import '../features/auth/register.dart';
import '../features/auth/forgot_password.dart';
import '../features/onboarding/onboarding_shell.dart';
import '../widgets/level_guard.dart';
import '../screens/loading_screen.dart';
import '../screens/main_app_screen.dart';
import '../screens/padel_arena_app.dart';
import '../screens/lobbies_screen.dart';
import '../screens/browse_lobbies_screen.dart';
import '../screens/quick_assessment_screen.dart';

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(appStateProvider); // Watch for state changes
  
  return GoRouter(
    initialLocation: '/loading',
    redirect: (context, state) {
      // Get the current app state
      final currentAppState = ref.read(appStateProvider);
      final location = state.matchedLocation;
      
      print('🔄 Router redirect - Current state: $currentAppState, Location: $location');
      
      switch (currentAppState) {
        case AppState.loading:
          if (location != '/loading') {
            print('🔄 Redirecting to /loading (loading state)');
            return '/loading';
          }
          break;
          
        case AppState.unauthenticated:
          // Redirect to auth flow if not already there
          final authPaths = ['/welcome', '/login', '/register', '/forgot-password'];
          if (!authPaths.contains(location)) {
            print('🔄 Redirecting to /welcome (unauthenticated)');
            return '/welcome';
          }
          break;
          
        case AppState.onboarding:
          // Redirect to onboarding if not already there
          if (location != '/onboarding') {
            print('🔄 Redirecting to /onboarding');
            return '/onboarding';
          }
          break;
          
        case AppState.authenticated:
          // Redirect away from auth/onboarding if authenticated
          final restrictedPaths = [
            '/loading', '/welcome', '/login', '/register', 
            '/forgot-password', '/onboarding'
          ];
          if (restrictedPaths.contains(location)) {
            print('🔄 Redirecting to /home (authenticated)');
            return '/home';
          }
          break;
      }
      
      print('🔄 No redirect needed');
      return null; // No redirect needed
    },
    routes: [
      // Loading screen
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      
      // Authentication routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => WelcomeScreen(
          onContinueWithGoogle: () async {
            try {
              print('🔵 Google Sign-In button pressed from WelcomeScreen');
              final credential = await AuthService.signInWithGoogle();
              
              if (credential.user != null) {
                await FirestoreService.createUserProfile(
                  userId: credential.user!.uid,
                  email: credential.user!.email!,
                  displayName: credential.user!.displayName,
                  photoURL: credential.user!.photoURL,
                  additionalData: {
                    'signUpMethod': 'google',
                    'platform': 'web',
                    'lastLoginAt': DateTime.now().toIso8601String(),
                  },
                );
                
                await AnalyticsService.logLogin(method: 'google');
                await AnalyticsService.setUserId(credential.user!.uid);
                
                // Navigation will be handled automatically by router redirect
                print('✅ Google Sign-In successful, router should redirect');
              }
            } catch (e) {
              print('❌ Google Sign-In failed: $e');
              if (context.mounted) {
                AppSnack.error(context, 'Google sign-in failed: ${e.toString()}');
              }
            }
          },
          onContinueWithApple: () async {
            try {
              print('🔵 Apple Sign-In button pressed from WelcomeScreen');
              if (kIsWeb) {
                if (context.mounted) {
                  AppSnack.error(context, 'Apple Sign-In is not available on web');
                }
                return;
              }
              
              final credential = await AuthService.signInWithApple();
              
              if (credential.user != null) {
                await FirestoreService.createUserProfile(
                  userId: credential.user!.uid,
                  email: credential.user!.email!,
                  displayName: credential.user!.displayName,
                  photoURL: credential.user!.photoURL,
                  additionalData: {
                    'signUpMethod': 'apple',
                    'platform': 'mobile',
                    'lastLoginAt': DateTime.now().toIso8601String(),
                  },
                );
                
                await AnalyticsService.logLogin(method: 'apple');
                await AnalyticsService.setUserId(credential.user!.uid);
                
                print('✅ Apple Sign-In successful, router should redirect');
              }
            } catch (e) {
              print('❌ Apple Sign-In failed: $e');
              if (context.mounted) {
                AppSnack.error(context, 'Apple sign-in failed: ${e.toString()}');
              }
            }
          },
          onCreateAccount: () => context.go('/register'),
          onLogin: () => context.go('/login'),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          onBackPressed: () => context.go('/welcome'),
          onForgotPassword: () => context.go('/forgot-password'),
          onCreateAccount: () => context.go('/register'),
          onLogin: (email, password) async {
            try {
              print('🔵 Email/Password login attempt: $email');
              final credential = await AuthService.signInWithEmail(
                email: email,
                password: password,
              );
              
              if (credential.user != null) {
                await AnalyticsService.logLogin(method: 'email');
                await AnalyticsService.setUserId(credential.user!.uid);
                
                print('✅ Email login successful, router should redirect');
                // Navigation will be handled automatically by router redirect
              }
            } catch (e) {
              print('❌ Email login failed: $e');
              if (context.mounted) {
                AppSnack.error(context, 'Login failed: ${e.toString()}');
              }
            }
          },
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(
          onBackPressed: () => context.go('/welcome'),
          onLoginPressed: () => context.go('/login'),
          onRegister: (email, password, displayName) async {
            try {
              print('🔵 Registration attempt: $email');
              final credential = await AuthService.registerWithEmail(
                email: email,
                password: password,
                displayName: displayName,
              );
              
              if (credential.user != null) {
                // Create user profile
                await FirestoreService.createUserProfile(
                  userId: credential.user!.uid,
                  email: email,
                  displayName: displayName,
                  additionalData: {
                    'signUpMethod': 'email',
                    'platform': 'web',
                  },
                );
                
                await AnalyticsService.logSignUp(method: 'email');
                await AnalyticsService.setUserId(credential.user!.uid);
                
                print('✅ Registration successful, router should redirect');
                // Navigation will be handled automatically by router redirect
              }
            } catch (e) {
              print('❌ Registration failed: $e');
              if (context.mounted) {
                AppSnack.error(context, 'Registration failed: ${e.toString()}');
              }
            }
          },
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordScreen(
          onBackPressed: () => context.go('/welcome'),
          onBackToLogin: () => context.go('/login'),
          onResetPassword: (email) async {
            try {
              print('🔵 Password reset request: $email');
              await AuthService.sendPasswordResetEmail(email);
              
              if (context.mounted) {
                AppSnack.success(context, 'Password reset email sent! Check your inbox.');
                // Stay on the same screen or redirect to login
                context.go('/login');
              }
            } catch (e) {
              print('❌ Password reset failed: $e');
              if (context.mounted) {
                AppSnack.error(context, 'Password reset failed: ${e.toString()}');
              }
            }
          },
        ),
      ),
      
      // Onboarding route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingShell(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const PadelArenaApp(),
      ),
      
      // Protected route example - Lobbies (requires skill level)
      GoRoute(
        path: '/lobbies',
        builder: (context, state) => Consumer(
          builder: (context, ref, child) {
            final user = ref.watch(currentUserProvider).value;
            return LevelGuard(
              user: user,
              onCompleteLevel: () {
                // Navigate to quiz or show quick assessment
                context.push('/quick-assessment');
              },
              child: const BrowseLobbiesScreen(),
            );
          },
        ),
      ),
      
      // Quick assessment route
      GoRoute(
        path: '/quick-assessment',
        builder: (context, state) => const QuickAssessmentScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Navigation helper methods provider
final navigationProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});

/// Navigation service for common navigation actions
class NavigationService {
  final Ref ref;
  
  NavigationService(this.ref);
  
  GoRouter get _router => ref.read(routerProvider);
  
  /// Navigate to login
  void goToLogin() => _router.go('/login');
  
  /// Navigate to register
  void goToRegister() => _router.go('/register');
  
  /// Navigate to home
  void goToHome() => _router.go('/home');
  
  /// Navigate to onboarding
  void goToOnboarding() => _router.go('/onboarding');
  
  /// Navigate to lobbies
  void goToLobbies() => _router.go('/lobbies');
  
  /// Go back
  void goBack() => _router.pop();
  
  /// Push route
  void push(String route) => _router.push(route);
  
  /// Replace current route
  void replace(String route) => _router.pushReplacement(route);
}