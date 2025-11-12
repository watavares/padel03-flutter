import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/design_system.dart';
import '../../widgets/snack.dart';
import '../../services/auth_service.dart';

/// Welcome screen - Professional authentication experience
class WelcomeScreen extends StatefulWidget {
  final VoidCallback? onContinueWithGoogle;
  final VoidCallback? onContinueWithApple;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onLogin;

  const WelcomeScreen({
    super.key,
    this.onContinueWithGoogle,
    this.onContinueWithApple,
    this.onCreateAccount,
    this.onLogin,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );



    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));



    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildContent(context, size, isTablet, isLandscape),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Size size, bool isTablet, bool isLandscape) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
      ),
      child: isLandscape
          ? _buildLandscapeLayout(context, size, isTablet)
          : _buildPortraitLayout(context, size, isTablet),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, Size size, bool isTablet) {
    return Column(
      children: [
        Expanded(
          flex: isTablet ? 3 : 2,
          child: _buildHeroSection(context, size, isTablet),
        ),
        Expanded(
          flex: isTablet ? 4 : 3,
          child: _buildAuthSection(context, size, isTablet),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, Size size, bool isTablet) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildHeroSection(context, size, isTablet),
        ),
        Expanded(
          flex: 2,
          child: _buildAuthSection(context, size, isTablet),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, Size size, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? PadelSpacing.xxxl : PadelSpacing.xl,
        vertical: PadelSpacing.xl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Clean logo - simple icon
          Container(
            width: isTablet ? 80 : 64,
            height: isTablet ? 80 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              Icons.sports_tennis_rounded,
              size: isTablet ? 40 : 32,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: PadelSpacing.xxl),
          
          const SizedBox(height: PadelSpacing.xl),
          
          // App name with clean typography
          Text(
            'PadelArena',
            style: (isTablet ? Theme.of(context).textTheme.displayLarge : Theme.of(context).textTheme.displayMedium)?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: PadelSpacing.md),
          
          // Clean subtitle
          Text(
            'Connect. Play. Win.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context, Size size, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? PadelSpacing.xxxl : PadelSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: size.width > size.height 
          ? const BorderRadius.horizontal(left: Radius.circular(32))
          : const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: PadelSpacing.xxl),
          
          // Welcome header with better hierarchy
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: (isTablet ? Theme.of(context).textTheme.displaySmall : Theme.of(context).textTheme.headlineMedium)?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: PadelSpacing.sm),
              Text(
                'Choose your preferred way to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PadelSpacing.xxxl),
          
          // Enhanced action buttons
          _buildEnhancedSocialButtons(context, isTablet),
          
          const SizedBox(height: PadelSpacing.xl),
          
          _buildDividerSection(),
          
          const SizedBox(height: PadelSpacing.xl),
          
          _buildEmailButtons(context, isTablet),
          
          const Spacer(),
          
          _buildModernFooter(context),
          
          SizedBox(height: isTablet ? PadelSpacing.xl : PadelSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildEnhancedSocialButtons(BuildContext context, bool isTablet) {
    return Column(
      children: [
        // Google Sign In with modern design
        _buildSocialButton(
          context: context,
          text: 'Continue with Google',
          icon: Icons.g_mobiledata_rounded,
          backgroundColor: Colors.white,
          textColor: Theme.of(context).colorScheme.onSurface,
          borderColor: Colors.grey.shade300,
          isLoading: _isGoogleLoading,
          onPressed: () => _handleGoogleSignIn(context),
        ),
        
        const SizedBox(height: PadelSpacing.md),
        
        // Apple Sign In (conditional)
        FutureBuilder<bool>(
          future: _checkAppleSignInAvailability(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return Column(
                children: [
                  _buildSocialButton(
                    context: context,
                    text: 'Continue with Apple',
                    icon: Icons.apple_rounded,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    isLoading: _isAppleLoading,
                    onPressed: () => _handleAppleSignIn(context),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
            child: Row(
              children: [
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 24,
                    color: textColor,
                  ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: Text(
                    text,
                    style: PadelTypography.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 24), // Balance the icon
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDividerSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PadelSpacing.md,
              vertical: PadelSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'or continue with email',
              style: PadelTypography.bodySmall.copyWith(
                color: PadelColors.textSecondary,
                fontWeight: FontWeight.w500,
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
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailButtons(BuildContext context, bool isTablet) {
    return Column(
      children: [
        // Create account button - use theme
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: widget.onCreateAccount,
            child: const Text('Create account'),
          ),
        ),
        
        const SizedBox(height: PadelSpacing.md),
        
        // Sign in button - use theme
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: widget.onLogin,
            child: const Text('Sign in'),
          ),
        ),
      ],
    );
  }



  Widget _buildModernFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.sm),
      child: Column(
        children: [
          Text(
            'By continuing, you agree to our',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PadelSpacing.xs),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink('Terms of Service', () {
                // Navigate to Terms of Service
              }),
              Text(
                ' and ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              _buildFooterLink('Privacy Policy', () {
                // Navigate to Privacy Policy
              }),
            ],
          ),
          const SizedBox(height: PadelSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PadelSpacing.md,
              vertical: PadelSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: PadelColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.security_rounded,
                  size: 16,
                  color: PadelColors.primary,
                ),
                const SizedBox(width: PadelSpacing.xs),
                Text(
                  'Secure & Private',
                  style: PadelTypography.caption.copyWith(
                    color: PadelColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PadelSpacing.xs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: PadelColors.primary.withOpacity(0.6),
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isGoogleLoading = true);
    
    try {
      HapticFeedback.lightImpact();
      widget.onContinueWithGoogle?.call();
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, 'Google sign-in failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    setState(() => _isAppleLoading = true);
    
    try {
      HapticFeedback.lightImpact();
      widget.onContinueWithApple?.call();
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, 'Apple sign-in failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  Future<bool> _checkAppleSignInAvailability() async {
    try {
      return await AuthService.isAppleSignInAvailable();
    } catch (e) {
      return false;
    }
  }
}