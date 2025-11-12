import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/design_system.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/snack.dart';

/// Register screen for creating new accounts
class RegisterScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onLoginPressed;
  final Function(String email, String password, String displayName)? onRegister;

  const RegisterScreen({
    super.key,
    this.onBackPressed,
    this.onLoginPressed,
    this.onRegister,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

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
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          'Create account',
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
            _buildRegistrationForm(),
            const SizedBox(height: PadelSpacing.lg),
            _buildTermsAndConditions(),
            const SizedBox(height: PadelSpacing.xl),
            _buildRegisterButton(),
            const SizedBox(height: PadelSpacing.xxxl),
            _buildLoginSection(),
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
          'Join PadelArena',
          style: PadelTypography.h3.copyWith(
            color: PadelColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PadelSpacing.md),
        Text(
          'Create your account to start connecting with players and finding courts',
          style: PadelTypography.bodyMedium.copyWith(
            color: PadelColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Display name field
          TextFormField(
            controller: _displayNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: _validateDisplayName,
            onChanged: (_) => _clearFormErrors(),
          ),
          
          const SizedBox(height: PadelSpacing.lg),
          
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
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a password',
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
          ),
          
          const SizedBox(height: PadelSpacing.lg),
          
          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Confirm password',
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: _validateConfirmPassword,
            onChanged: (_) => _clearFormErrors(),
            onFieldSubmitted: (_) => _handleRegister(),
          ),
          
          const SizedBox(height: PadelSpacing.md),
          
          // Password requirements
          _buildPasswordRequirements(),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
    
    return Container(
      padding: const EdgeInsets.all(PadelSpacing.md),
      decoration: BoxDecoration(
        color: PadelColors.grey100,
        borderRadius: BorderRadius.circular(PadelRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password requirements:',
            style: PadelTypography.labelSmall.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.sm),
          _buildRequirement('At least 6 characters', password.length >= 6),
          _buildRequirement('Contains uppercase letter', password.contains(RegExp(r'[A-Z]'))),
          _buildRequirement('Contains lowercase letter', password.contains(RegExp(r'[a-z]'))),
          _buildRequirement('Contains number', password.contains(RegExp(r'[0-9]'))),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? PadelColors.success : PadelColors.grey400,
        ),
        const SizedBox(width: PadelSpacing.sm),
        Text(
          text,
          style: PadelTypography.bodySmall.copyWith(
            color: isMet ? PadelColors.success : PadelColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: PadelColors.secondary,
        ),
        const SizedBox(width: PadelSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: PadelTypography.bodySmall.copyWith(
                color: PadelColors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: PadelTypography.bodySmall.copyWith(
                    color: PadelColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: PadelTypography.bodySmall.copyWith(
                    color: PadelColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return PrimaryButton(
      text: 'Create account',
      isLoading: _isLoading,
      onPressed: _acceptTerms ? _handleRegister : null,
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
              child: Text(
                'Already have an account?',
                style: PadelTypography.bodySmall.copyWith(
                  color: PadelColors.textTertiary,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: PadelSpacing.lg),
        
        // Login button
        SecondaryButton(
          text: 'Sign in',
          onPressed: widget.onLoginPressed,
        ),
      ],
    );
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
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
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  void _clearFormErrors() {
    // Clear any form-level errors when user types
    _formKey.currentState?.validate();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      AppSnack.error(context, 'Please accept the Terms of Service and Privacy Policy');
      return;
    }

    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      HapticFeedback.lightImpact();
      widget.onRegister?.call(email, password, displayName);
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