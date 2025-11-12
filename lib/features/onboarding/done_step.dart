import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/design_system.dart';
import '../../widgets/primary_button.dart';
import '../../providers/onboarding_providers.dart';

class DoneStep extends ConsumerStatefulWidget {
  const DoneStep({super.key});

  @override
  ConsumerState<DoneStep> createState() => _DoneStepState();
}

class _DoneStepState extends ConsumerState<DoneStep> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PadelSpacing.lg),
      child: Column(
        children: [
          const Spacer(),
          
          // Success animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: PadelColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(PadelRadius.full),
                      border: Border.all(
                        color: PadelColors.success.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: PadelColors.success,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: PadelSpacing.xxxl),
          
          // Success message
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Text(
              'You\'re all set!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: PadelColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: PadelSpacing.lg),
          
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Text(
              'Your profile is complete and you\'re ready to find padel partners and join games.',
              style: TextStyle(
                fontSize: 16,
                color: PadelColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: PadelSpacing.xxxl),
          
          // Features preview
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: Icons.location_on,
                  title: 'Find Courts',
                  description: 'Discover padel courts near you',
                ),
                const SizedBox(height: PadelSpacing.lg),
                _buildFeatureItem(
                  icon: Icons.group,
                  title: 'Join Games',
                  description: 'Connect with players of your level',
                ),
                const SizedBox(height: PadelSpacing.lg),
                _buildFeatureItem(
                  icon: Icons.calendar_today,
                  title: 'Schedule Matches',
                  description: 'Book courts and organize sessions',
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Start exploring button
          FadeTransition(
            opacity: _fadeAnimation,
            child: PrimaryButton(
              text: 'Start Exploring',
              onPressed: _handleStartExploring,
              isLoading: _isLoading,
              backgroundColor: PadelColors.accent,
              textColor: PadelColors.textOnAccent,
            ),
          ),
          const SizedBox(height: PadelSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: PadelColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(PadelRadius.md),
          ),
          child: Icon(
            icon,
            color: PadelColors.secondary,
            size: 24,
          ),
        ),
        const SizedBox(width: PadelSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PadelColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: PadelColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleStartExploring() async {
    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      
      // Mark onboarding as completed using the controller
      final onboardingController = ref.read(onboardingControllerProvider.notifier);
      await onboardingController.completeOnboarding();
      
      print('Onboarding completed successfully');
      print('Navigating to main app...');
      
      // The router will automatically redirect to /home when needsOnboarding becomes false
      
    } catch (e) {
      print('Error completing onboarding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}