import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class AvatarStep extends StatefulWidget {
  final VoidCallback onNext;
  
  const AvatarStep({
    super.key,
    required this.onNext,
  });

  @override
  State<AvatarStep> createState() => _AvatarStepState();
}

class _AvatarStepState extends State<AvatarStep> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  String? _selectedAvatar;
  bool _isNameValid = false;
  
  // Predefined avatar options
  final List<String> _avatarOptions = [
    '👤', '🏃‍♂️', '🏃‍♀️', '🧑‍💼', '👩‍💼', '🧑‍🎓', '👩‍🎓',
    '🧑‍⚕️', '👩‍⚕️', '👨‍🚀', '👩‍🚀', '🧑‍🎨', '👩‍🎨', '🧑‍🍳',
    '👩‍🍳', '🧑‍🌾', '👩‍🌾', '👨‍🏫', '👩‍🏫', '🧑‍💻', '👩‍💻',
    '🧑‍🔧', '👩‍🔧', '🧑‍✈️', '👩‍✈️', '🕵️‍♂️', '🕵️‍♀️', '💂‍♂️',
    '💂‍♀️', '👷‍♂️', '👷‍♀️', '🤴', '👸', '👳‍♂️', '👳‍♀️', '👲',
  ];
  
  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateName);
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isNameValid = _nameController.text.trim().length >= 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Complete your profile',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Add your name and choose an avatar. Other players will see this information.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar selection
                  const Text(
                    'Choose Avatar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Avatar grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1,
                    ),
                    itemCount: _avatarOptions.length,
                    itemBuilder: (context, index) {
                      final avatar = _avatarOptions[index];
                      final isSelected = _selectedAvatar == avatar;
                      
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedAvatar = avatar;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? AppColors.primaryBlue.withOpacity(0.1)
                              : AppColors.grey50,
                            border: Border.all(
                              color: isSelected 
                                ? AppColors.primaryBlue 
                                : AppColors.grey200,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Center(
                            child: Text(
                              avatar,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  
                  // Name field
                  const Text(
                    'Display Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.primaryBlue,
                      ),
                      suffixIcon: _isNameValid
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          )
                        : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.error),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                    maxLength: 30,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Bio field (optional)
                  const Text(
                    'Bio (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _bioController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tell others about yourself...',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                    maxLines: 3,
                    maxLength: 150,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Continue button
          PrimaryButton(
            text: 'Continue',
            onPressed: (_isNameValid && _selectedAvatar != null) ? _handleContinue : null,
            isLoading: false,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();
    
    // Save profile data
    final profileData = {
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'avatar': _selectedAvatar,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // TODO: Save to onboarding state
    print('Profile data: $profileData');
    
    widget.onNext();
  }
}