import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_text_field.dart';
import '../screens/padel_arena_app.dart';
import '../design_system/design_system.dart';

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
    if (!mounted) return;
    
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
    print('🔵 _signInWithGoogle called');
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      print('🔵 Calling AuthService.signInWithGoogle()...');
      final credential = await AuthService.signInWithGoogle();

      if (credential.user != null) {
        print('✅ Google Sign-In successful, creating user profile...');
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

        _showMessage(
          'Welcome back! Signed in with Google successfully.',
          MessageType.success,
        );

        // Add haptic feedback
        HapticFeedback.lightImpact();
        
        // Navigate to next screen based on user onboarding status
        // The router will handle this automatically based on app state
        print('🔵 Sign-in successful, router should redirect automatically');
      }
    } catch (e) {
      print('❌ Google sign in failed: $e');
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

  void _toggleSignUpMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _message = null;
      _formKey.currentState?.reset();
    });

    HapticFeedback.selectionClick();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isSignUp) {
      await _signUpWithEmail();
    } else {
      await _signInWithEmail();
    }
  }

  String _resetEmail = '';
  
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _resetEmail = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_resetEmail.isNotEmpty) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: _resetEmail);
                  Navigator.pop(context);
                  setState(() {
                    _message = 'Password reset email sent!';
                  });
                } catch (e) {
                  setState(() {
                    _message = 'Error: ${e.toString()}';
                  });
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
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
            // Redirect to main PadelArena app after successful authentication
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PadelArenaApp(),
                ),
              );
            });
            
            // Show loading while redirecting
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Redirecting to PadelArena...'),
                  ],
                ),
              ),
            );
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
            PadelColors.primary,
            PadelColors.primary.withOpacity(0.8),
            PadelColors.accent,
          ],
          stops: const [0.0, 0.6, 1.0],
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
                        maxWidth: isTablet ? 420 : double.infinity,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(PadelRadius.xl),
                          color: PadelColors.white,
                          boxShadow: [
                            PadelShadows.xl,
                            BoxShadow(
                              color: PadelColors.primary.withOpacity(0.1),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(PadelRadius.xl),
                          child: Column(
                            children: [
                              // Header with gradient background
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(PadelSpacing.xl),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      PadelColors.primary.withOpacity(0.05),
                                      PadelColors.accent.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: _buildHeader(theme),
                              ),
                              // Form content
                              Padding(
                                padding: EdgeInsets.all(PadelSpacing.xl),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      _buildFormFields(),
                                      SizedBox(height: PadelSpacing.xl),
                                      _buildActionButtons(theme),
                                      SizedBox(height: PadelSpacing.lg),
                                      _buildSocialButtons(),
                                      SizedBox(height: PadelSpacing.md),
                                      _buildToggleButton(theme),
                                      if (_message != null) ...[
                                        SizedBox(height: PadelSpacing.lg),
                                        _buildMessageCard(theme),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
        // Professional padel logo with modern design
        Hero(
          tag: 'padel_logo',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: PadelColors.accentGradient,
              shape: BoxShape.circle,
              boxShadow: [
                ...PadelShadows.floating,
                BoxShadow(
                  color: PadelColors.white.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Icon(
              Icons.sports_tennis, 
              size: 40, 
              color: PadelColors.textOnAccent,
            ),
          ),
        ),
        SizedBox(height: PadelSpacing.lg),
        
        // Brand name with sporty typography
        ShaderMask(
          shaderCallback: (bounds) => PadelColors.primaryGradient.createShader(bounds),
          child: Text(
            'PadelArena',
            style: PadelTypography.h1.copyWith(
              fontWeight: FontWeight.w900,
              color: PadelColors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: PadelSpacing.sm),
        
        // Dynamic welcome message
        Text(
          _isSignUp 
              ? 'Join the Ultimate Padel Community' 
              : 'Welcome Back, Champion',
          style: PadelTypography.h6.copyWith(
            color: PadelColors.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: PadelSpacing.sm),
        
        // Sporty tagline with modern badge design
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: PadelSpacing.lg, 
            vertical: PadelSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PadelColors.accent.withOpacity(0.1),
                PadelColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(PadelRadius.xl),
            border: Border.all(
              color: PadelColors.accent.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                size: 16,
                color: PadelColors.accent,
              ),
              SizedBox(width: PadelSpacing.xs),
              Text(
                'Train • Compete • Excel',
                style: PadelTypography.labelMedium.copyWith(
                  color: PadelColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
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
        // Main action button with professional sports styling
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: _isLoading 
                ? LinearGradient(colors: [PadelColors.grey300, PadelColors.grey300])
                : PadelColors.primaryGradient,
            borderRadius: BorderRadius.circular(PadelRadius.lg),
            boxShadow: _isLoading ? null : PadelShadows.button,
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: PadelColors.textOnAccent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PadelRadius.lg),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(PadelColors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(PadelSpacing.xs),
                        decoration: BoxDecoration(
                          color: PadelColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
                          size: 18,
                          color: PadelColors.textOnAccent,
                        ),
                      ),
                      SizedBox(width: PadelSpacing.md),
                      Text(
                        _isSignUp ? 'Join the Arena' : 'Enter the Arena',
                        style: PadelTypography.h6.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PadelColors.textOnAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        if (!_isSignUp) ...[
          SizedBox(height: PadelSpacing.lg),
          // Forgot password button with subtle styling
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PadelRadius.md),
              border: Border.all(
                color: PadelColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextButton(
              onPressed: _isLoading ? null : () => _showForgotPasswordDialog(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: PadelSpacing.lg, 
                  vertical: PadelSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PadelRadius.md),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    size: 16,
                    color: PadelColors.primary,
                  ),
                  SizedBox(width: PadelSpacing.sm),
                  Text(
                    'Forgot Password?',
                    style: PadelTypography.bodyMedium.copyWith(
                      color: PadelColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Modern divider with professional styling
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      PadelColors.grey300,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: PadelSpacing.md,
                  vertical: PadelSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: PadelColors.grey50,
                  borderRadius: BorderRadius.circular(PadelRadius.full),
                  border: Border.all(
                    color: PadelColors.grey200,
                    width: 1,
                  ),
                ),
                child: Text(
                  'OR CONTINUE WITH',
                  style: PadelTypography.labelSmall.copyWith(
                    color: PadelColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      PadelColors.grey300,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: PadelSpacing.lg),
        
        // Social buttons with modern card design
        Row(
          children: [
            if (_isGoogleAvailable) ...[
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: PadelColors.white,
                    borderRadius: BorderRadius.circular(PadelRadius.lg),
                    border: Border.all(
                      color: PadelColors.grey300,
                      width: 1.5,
                    ),
                    boxShadow: [PadelShadows.sm],
                  ),
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      print('🔵 Google Sign-In button pressed');
                      _signInWithGoogle();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PadelRadius.lg),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: PadelSpacing.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(PadelSpacing.xs),
                          decoration: BoxDecoration(
                            color: PadelColors.grey50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.g_mobiledata,
                            size: 18,
                            color: PadelColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: PadelSpacing.sm),
                        Text(
                          'Google',
                          style: PadelTypography.bodyMedium.copyWith(
                            color: PadelColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isAppleAvailable) SizedBox(width: PadelSpacing.md),
            ],
            if (_isAppleAvailable) ...[
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: PadelColors.textPrimary,
                    borderRadius: BorderRadius.circular(PadelRadius.lg),
                    boxShadow: [PadelShadows.sm],
                  ),
                  child: TextButton(
                    onPressed: _isLoading ? null : _signInWithApple,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PadelRadius.lg),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: PadelSpacing.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(PadelSpacing.xs),
                          decoration: BoxDecoration(
                            color: PadelColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.apple,
                            size: 18,
                            color: PadelColors.white,
                          ),
                        ),
                        SizedBox(width: PadelSpacing.sm),
                        Text(
                          'Apple',
                          style: PadelTypography.bodyMedium.copyWith(
                            color: PadelColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: PadelSpacing.lg,
        vertical: PadelSpacing.md,
      ),
      decoration: BoxDecoration(
        color: PadelColors.grey50,
        borderRadius: BorderRadius.circular(PadelRadius.lg),
        border: Border.all(
          color: PadelColors.grey200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isSignUp ? 'Already have an account?' : "Don't have an account?",
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          SizedBox(width: PadelSpacing.sm),
          GestureDetector(
            onTap: _isLoading ? null : _toggleSignUpMode,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: PadelSpacing.md,
                vertical: PadelSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: PadelColors.accentGradient,
                borderRadius: BorderRadius.circular(PadelRadius.md),
                boxShadow: [PadelShadows.sm],
              ),
              child: Text(
                _isSignUp ? 'Sign In' : 'Join Now',
                style: PadelTypography.labelMedium.copyWith(
                  color: PadelColors.textOnAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(ThemeData theme) {
    final colors = {
      MessageType.success: PadelColors.success,
      MessageType.error: PadelColors.error,
      MessageType.info: PadelColors.primary,
    };

    final backgroundColors = {
      MessageType.success: PadelColors.success.withOpacity(0.1),
      MessageType.error: PadelColors.error.withOpacity(0.1),
      MessageType.info: PadelColors.primary.withOpacity(0.1),
    };

    final icons = {
      MessageType.success: Icons.check_circle_outline,
      MessageType.error: Icons.error_outline,
      MessageType.info: Icons.info_outline,
    };

    return Container(
      padding: EdgeInsets.all(PadelSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColors[_messageType],
        borderRadius: BorderRadius.circular(PadelRadius.md),
        border: Border.all(
          color: colors[_messageType]!,
          width: 1,
        ),
        boxShadow: [PadelShadows.sm],
      ),
      child: Row(
        children: [
          Icon(
            icons[_messageType], 
            color: colors[_messageType], 
            size: 20,
          ),
          SizedBox(width: PadelSpacing.sm),
          Expanded(
            child: Text(
              _message!,
              style: PadelTypography.bodySmall.copyWith(
                color: colors[_messageType],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

enum MessageType { success, error, info }
