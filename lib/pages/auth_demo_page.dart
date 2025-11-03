import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/firestore_service.dart';

class AuthDemoPage extends StatefulWidget {
  const AuthDemoPage({super.key});

  @override
  State<AuthDemoPage> createState() => _AuthDemoPageState();
}

class _AuthDemoPageState extends State<AuthDemoPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleAvailable = false;
  bool _isAppleAvailable = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _checkProviderAvailability();
  }

  Future<void> _checkProviderAvailability() async {
    final isGoogleAvailable = await AuthService.isGoogleSignInAvailable();
    final isAppleAvailable = await AuthService.isAppleSignInAvailable();
    
    setState(() {
      _isGoogleAvailable = isGoogleAvailable;
      _isAppleAvailable = isAppleAvailable;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final credential = await AuthService.signInWithGoogle();

      if (credential?.user != null) {
        // Create or update user profile in Firestore
        await FirestoreService.createUserProfile(
          userId: credential!.user!.uid,
          email: credential.user!.email!,
          displayName: credential.user!.displayName,
          photoURL: credential.user!.photoURL,
          additionalData: {
            'signUpMethod': 'google',
            'platform': 'web',
          },
        );

        // Log analytics event
        await AnalyticsService.logLogin(method: 'google');
        await AnalyticsService.setUserId(credential.user!.uid);

        setState(() {
          _message = 'Signed in with Google successfully!';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Google sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final credential = await AuthService.signInWithApple();

      if (credential?.user != null) {
        // Create or update user profile in Firestore
        await FirestoreService.createUserProfile(
          userId: credential!.user!.uid,
          email: credential.user!.email!,
          displayName: credential.user!.displayName,
          photoURL: credential.user!.photoURL,
          additionalData: {
            'signUpMethod': 'apple',
            'platform': 'web',
          },
        );

        // Log analytics event
        await AnalyticsService.logLogin(method: 'apple');
        await AnalyticsService.setUserId(credential.user!.uid);

        setState(() {
          _message = 'Signed in with Apple successfully!';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Apple sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final credential = await AuthService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      );

      if (credential?.user != null) {
        // Create user profile in Firestore
        await FirestoreService.createUserProfile(
          userId: credential!.user!.uid,
          email: credential.user!.email!,
          displayName: credential.user!.displayName,
          additionalData: {
            'signUpMethod': 'email',
            'platform': 'web',
          },
        );

        // Log analytics event
        await AnalyticsService.logSignUp(method: 'email');
        await AnalyticsService.setUserId(credential.user!.uid);

        setState(() {
          _message = 'Account created successfully! Please check your email for verification.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Sign up failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = 'Please fill in email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final credential = await AuthService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (credential?.user != null) {
        // Update last login in Firestore
        await FirestoreService.update(
          'users',
          credential!.user!.uid,
          {'lastLoginAt': DateTime.now().toIso8601String()},
        );

        // Log analytics event
        await AnalyticsService.logLogin(method: 'email');
        await AnalyticsService.setUserId(credential.user!.uid);

        setState(() {
          _message = 'Signed in successfully!';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signOut();
      await AnalyticsService.setUserId(null);
      
      setState(() {
        _message = 'Signed out successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Sign out failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder(
        stream: AuthService.authStateChanges,
        builder: (context, snapshot) {
          final user = snapshot.data;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (user != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Signed in as:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Email: ${user.email}'),
                          Text('UID: ${user.uid}'),
                          Text('Display Name: ${user.displayName ?? 'Not set'}'),
                          Text('Email Verified: ${user.emailVerified}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signOut,
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Authentication Demo',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signUp,
                                  child: _isLoading 
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Sign Up'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signIn,
                                  child: _isLoading 
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Sign In'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),
                          Text(
                            'Or sign in with:',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          if (_isGoogleAvailable) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _signInWithGoogle,
                                icon: const Icon(Icons.g_mobiledata, size: 24),
                                label: const Text('Continue with Google'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  side: const BorderSide(color: Colors.grey),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_isAppleAvailable) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _signInWithApple,
                                icon: const Icon(Icons.apple, size: 24),
                                label: const Text('Continue with Apple'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: _message!.contains('successfully') 
                        ? Colors.green.shade50 
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.contains('successfully') 
                              ? Colors.green.shade700 
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}