import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/design_system.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/snack.dart';

/// Login screen for email/password authentication
class LoginScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onCreateAccount;
  final Function(String email, String password)? onLogin;

  const LoginScreen({
    super.key,
    this.onBackPressed,
    this.onForgotPassword,
    this.onCreateAccount,
    this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: PadelColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: widget.onBackPressed,
        ),
        title: Text(
          'Welcome back',
          style: PadelTypography.h5.copyWith(
            color: PadelColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(context, size, isTablet),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Size size, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48.0 : 24.0,
        vertical: 32.0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 420 : double.infinity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: PadelSpacing.xxxl),
            _buildLoginForm(),
            const SizedBox(height: PadelSpacing.xl),
            _buildLoginButton(),
            const SizedBox(height: PadelSpacing.lg),
            _buildForgotPassword(),
            const SizedBox(height: PadelSpacing.xxxl),
            _buildCreateAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign in to continue',
          style: PadelTypography.h3.copyWith(
            color: PadelColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PadelSpacing.md),
        Text(
          'Enter your email and password to access your account',
          style: PadelTypography.bodyMedium.copyWith(
            color: PadelColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: _validateEmail,
            onChanged: (_) => _clearFormErrors(),
          ),
          
          const SizedBox(height: PadelSpacing.lg),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: _validatePassword,
            onChanged: (_) => _clearFormErrors(),
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          
          const SizedBox(height: PadelSpacing.lg),
          
          // Remember me checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: PadelColors.secondary,
              ),
              const SizedBox(width: PadelSpacing.sm),
              Text(
                'Remember me',
                style: PadelTypography.bodyMedium.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return PrimaryButton(
      text: 'Sign in',
      isLoading: _isLoading,
      onPressed: _handleLogin,
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: widget.onForgotPassword,
        child: Text(
          'Forgot your password?',
          style: PadelTypography.bodyMedium.copyWith(
            color: PadelColors.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountSection() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
              child: Text(
                'Don\'t have an account?',
                style: PadelTypography.bodySmall.copyWith(
                  color: PadelColors.textTertiary,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: PadelSpacing.lg),
        
        // Create account button
        SecondaryButton(
          text: 'Create account',
          onPressed: widget.onCreateAccount,
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  void _clearFormErrors() {
    // Clear any form-level errors when user types
    _formKey.currentState?.validate();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      HapticFeedback.lightImpact();
      widget.onLogin?.call(email, password);
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}