import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';

class ModernLoginPage extends StatefulWidget {
  const ModernLoginPage({super.key});

  @override
  State<ModernLoginPage> createState() => _ModernLoginPageState();
}

class _ModernLoginPageState extends State<ModernLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isSignUp = false;
  bool _isPasswordVisible = false;
  bool _isGoogleAvailable = false;
  bool _isAppleAvailable = false;
  String? _message;
  MessageType _messageType = MessageType.info;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkProviderAvailability();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
          ),
        );

    _animationController.forward();
  }

  Future<void> _checkProviderAvailability() async {
    final isGoogleAvailable = await AuthService.isGoogleSignInAvailable();
    final isAppleAvailable = await AuthService.isAppleSignInAvailable();

    if (mounted) {
      setState(() {
        _isGoogleAvailable = isGoogleAvailable;
        _isAppleAvailable = isAppleAvailable;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message, MessageType type) {
    setState(() {
      _message = message;
      _messageType = type;
    });

    // Auto-clear success messages after 3 seconds
    if (type == MessageType.success) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _message == message) {
          setState(() {
            _message = null;
          });
        }
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final credential = await AuthService.signInWithGoogle();

      if (credential?.user != null) {
        await FirestoreService.createUserProfile(
          userId: credential!.user!.uid,
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

        _showMessage(
          'Welcome back! Signed in with Google successfully.',
          MessageType.success,
        );

        // Add haptic feedback
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showMessage('Google sign in failed: ${e.toString()}', MessageType.error);
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        await FirestoreService.createUserProfile(
          userId: credential!.user!.uid,
          email: credential.user!.email!,
          displayName: credential.user!.displayName,
          photoURL: credential.user!.photoURL,
          additionalData: {
            'signUpMethod': 'apple',
            'platform': 'web',
            'lastLoginAt': DateTime.now().toIso8601String(),
          },
        );

        await AnalyticsService.logLogin(method: 'apple');
        await AnalyticsService.setUserId(credential.user!.uid);

        _showMessage(
          'Welcome! Signed in with Apple successfully.',
          MessageType.success,
        );
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showMessage('Apple sign in failed: ${e.toString()}', MessageType.error);
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final credential = await AuthService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
      );

      if (credential?.user != null) {
        await FirestoreService.createUserProfile(
          userId: credential!.user!.uid,
          email: credential.user!.email!,
          displayName: credential.user!.displayName,
          additionalData: {
            'signUpMethod': 'email',
            'platform': 'web',
            'createdAt': DateTime.now().toIso8601String(),
          },
        );

        await AnalyticsService.logSignUp(method: 'email');
        await AnalyticsService.setUserId(credential.user!.uid);

        _showMessage(
          'Account created successfully! Please check your email for verification.',
          MessageType.success,
        );
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showMessage('Sign up failed: ${e.toString()}', MessageType.error);
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

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
        await FirestoreService.update('users', credential!.user!.uid, {
          'lastLoginAt': DateTime.now().toIso8601String(),
        });

        await AnalyticsService.logLogin(method: 'email');
        await AnalyticsService.setUserId(credential.user!.uid);

        _showMessage(
          'Welcome back! Signed in successfully.',
          MessageType.success,
        );
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showMessage('Sign in failed: ${e.toString()}', MessageType.error);
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signOut();
      await AnalyticsService.setUserId(null);

      _showMessage('Signed out successfully!', MessageType.success);
      HapticFeedback.lightImpact();

      // Clear form
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    } catch (e) {
      _showMessage('Sign out failed: ${e.toString()}', MessageType.error);
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSignUpMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _message = null;
      _formKey.currentState?.reset();
    });

    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: StreamBuilder(
        stream: AuthService.authStateChanges,
        builder: (context, snapshot) {
          final user = snapshot.data;

          if (user != null) {
            return _buildUserProfile(user, theme);
          }

          return _buildLoginForm(theme, size, isTablet);
        },
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, Size size, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 48.0 : 24.0,
              vertical: 32.0,
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 400 : double.infinity,
                      ),
                      child: Card(
                        elevation: 8,
                        shadowColor: theme.primaryColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(theme),
                                const SizedBox(height: 32),
                                _buildFormFields(),
                                const SizedBox(height: 24),
                                _buildActionButtons(theme),
                                const SizedBox(height: 24),
                                _buildSocialButtons(),
                                const SizedBox(height: 16),
                                _buildToggleButton(theme),
                                if (_message != null) ...[
                                  const SizedBox(height: 16),
                                  _buildMessageCard(theme),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.sports_tennis, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Padel03',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp ? 'Create your account' : 'Welcome back',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        if (_isSignUp) ...[
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: _isSignUp
                ? (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 16),
        ],
        CustomTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
          isPasswordVisible: _isPasswordVisible,
          onTogglePassword: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your password';
            }
            if (_isSignUp && value!.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        CustomButton(
          onPressed: _isLoading
              ? null
              : (_isSignUp ? _signUpWithEmail : _signInWithEmail),
          isLoading: _isLoading,
          text: _isSignUp ? 'Create Account' : 'Sign In',
          style: CustomButtonStyle.primary,
        ),
        if (!_isSignUp) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    // TODO: Implement forgot password
                    _showMessage(
                      'Forgot password feature coming soon!',
                      MessageType.info,
                    );
                  },
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_isGoogleAvailable) ...[
              Expanded(
                child: SocialLoginButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Icons.g_mobiledata,
                  label: 'Google',
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey[300],
                ),
              ),
              if (_isAppleAvailable) const SizedBox(width: 12),
            ],
            if (_isAppleAvailable) ...[
              Expanded(
                child: SocialLoginButton(
                  onPressed: _isLoading ? null : _signInWithApple,
                  icon: Icons.apple,
                  label: 'Apple',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account?' : "Don't have an account?",
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: _isLoading ? null : _toggleSignUpMode,
          child: Text(
            _isSignUp ? 'Sign In' : 'Sign Up',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(ThemeData theme) {
    final colors = {
      MessageType.success: Colors.green,
      MessageType.error: Colors.red,
      MessageType.info: theme.primaryColor,
    };

    final icons = {
      MessageType.success: Icons.check_circle_outline,
      MessageType.error: Icons.error_outline,
      MessageType.info: Icons.info_outline,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors[_messageType]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors[_messageType]!.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icons[_messageType], color: colors[_messageType], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message!,
              style: TextStyle(color: colors[_messageType], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(user, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.primaryColor.withOpacity(0.1), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: theme.primaryColor,
                              )
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.displayName ?? 'User',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.emailVerified
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.emailVerified ? 'Verified' : 'Unverified',
                          style: TextStyle(
                            color: user.emailVerified
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        onPressed: _isLoading ? null : _signOut,
                        isLoading: _isLoading,
                        text: 'Sign Out',
                        style: CustomButtonStyle.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum MessageType { success, error, info }
