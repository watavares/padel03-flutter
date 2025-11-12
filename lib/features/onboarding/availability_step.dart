import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class AvailabilityStep extends StatefulWidget {
  final VoidCallback onNext;
  
  const AvailabilityStep({
    super.key,
    required this.onNext,
  });

  @override
  State<AvailabilityStep> createState() => _AvailabilityStepState();
}

class _AvailabilityStepState extends State<AvailabilityStep> {
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  
  final List<String> _timeSlots = [
    'Early Morning (6:00 - 9:00)',
    'Morning (9:00 - 12:00)',
    'Afternoon (12:00 - 17:00)',
    'Evening (17:00 - 20:00)',
    'Night (20:00 - 23:00)',
  ];

  final Map<String, List<String>> _selectedAvailability = {};
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'When do you like to play?',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Select your preferred days and times. This helps us suggest games that fit your schedule.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          
          // Availability grid
          Expanded(
            child: ListView.separated(
              itemCount: _daysOfWeek.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, dayIndex) {
                final day = _daysOfWeek[dayIndex];
                final daySelected = _selectedAvailability.containsKey(day);
                
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: daySelected ? AppColors.primaryBlue : AppColors.grey200,
                      width: daySelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    color: AppColors.white,
                  ),
                  child: Column(
                    children: [
                      // Day header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: daySelected 
                            ? AppColors.primaryBlue.withOpacity(0.05)
                            : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadius.lg - 1),
                            topRight: Radius.circular(AppRadius.lg - 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: daySelected,
                              onChanged: (value) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  if (value == true) {
                                    _selectedAvailability[day] = [];
                                  } else {
                                    _selectedAvailability.remove(day);
                                  }
                                });
                              },
                              activeColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              day,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: daySelected 
                                  ? AppColors.primaryBlue 
                                  : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Time slots (only show if day is selected)
                      if (daySelected) ...[
                        const Divider(height: 1, color: AppColors.grey200),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preferred times:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: _timeSlots.map((timeSlot) {
                                  final isSelected = _selectedAvailability[day]?.contains(timeSlot) ?? false;
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        if (_selectedAvailability[day] == null) {
                                          _selectedAvailability[day] = [];
                                        }
                                        
                                        if (isSelected) {
                                          _selectedAvailability[day]!.remove(timeSlot);
                                        } else {
                                          _selectedAvailability[day]!.add(timeSlot);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                          ? AppColors.primaryBlue 
                                          : AppColors.grey100,
                                        borderRadius: BorderRadius.circular(AppRadius.round),
                                        border: Border.all(
                                          color: isSelected 
                                            ? AppColors.primaryBlue 
                                            : AppColors.grey200,
                                        ),
                                      ),
                                      child: Text(
                                        timeSlot,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected 
                                            ? Colors.white 
                                            : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Continue button
          PrimaryButton(
            text: 'Continue',
            onPressed: _selectedAvailability.isNotEmpty ? _handleContinue : null,
            isLoading: false,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();
    
    // Save availability data
    final availabilityData = {
      'availability': _selectedAvailability,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // TODO: Save to onboarding state
    print('Availability data: $availabilityData');
    
    widget.onNext();
  }
}