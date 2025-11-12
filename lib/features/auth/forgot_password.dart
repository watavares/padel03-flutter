import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/snack.dart';

/// Forgot password screen for password reset
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onBackToLogin;
  final Function(String email)? onResetPassword;

  const ForgotPasswordScreen({
    super.key,
    this.onBackPressed,
    this.onBackToLogin,
    this.onResetPassword,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _emailSent = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: widget.onBackPressed,
        ),
        title: Text(
          'Reset password',
          style: AppTypography.h5.copyWith(
            color: AppColors.textPrimary,
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
          children: [
            if (_emailSent) 
              _buildSuccessContent()
            else 
              _buildResetForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.xxxl),
        _buildEmailForm(),
        const SizedBox(height: AppSpacing.xl),
        _buildResetButton(),
        const SizedBox(height: AppSpacing.lg),
        _buildBackToLogin(),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.massive),
        
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 40,
            color: AppColors.success,
          ),
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Success title
        Text(
          'Check your email',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Success message
        Text(
          'We\'ve sent password reset instructions to',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        Text(
          _emailController.text.trim(),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.info.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outlined,
                    size: 20,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Next steps:',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '1. Check your email inbox\n'
                '2. Click the reset link in the email\n'
                '3. Create a new password\n'
                '4. Sign in with your new password',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Action buttons
        PrimaryButton(
          text: 'Back to login',
          onPressed: widget.onBackToLogin,
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        SecondaryButton(
          text: 'Resend email',
          onPressed: _handleResendEmail,
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Note about spam folder
        Text(
          'Didn\'t receive the email? Check your spam folder or try resending.',
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot your password?',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Enter your email address and we\'ll send you instructions to reset your password.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Email address',
          hintText: 'Enter your email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: _validateEmail,
        onFieldSubmitted: (_) => _handleResetPassword(),
      ),
    );
  }

  Widget _buildResetButton() {
    return PrimaryButton(
      text: 'Send reset instructions',
      isLoading: _isLoading,
      onPressed: _handleResetPassword,
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: TextButton(
        onPressed: widget.onBackToLogin,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Back to login',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
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

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() => _isLoading = true);

    try {
      HapticFeedback.lightImpact();
      widget.onResetPassword?.call(email);
      
      // Show success state
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
      
      if (mounted) {
        AppSnack.success(context, 'Password reset email sent successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendEmail() async {
    final email = _emailController.text.trim();
    
    try {
      HapticFeedback.lightImpact();
      widget.onResetPassword?.call(email);
      
      if (mounted) {
        AppSnack.success(context, 'Reset email resent successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, e.toString());
      }
    }
  }
}