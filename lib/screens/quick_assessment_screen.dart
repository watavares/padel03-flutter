import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../providers/analytics_providers.dart';
import '../models/user_model.dart';

class QuickAssessmentScreen extends ConsumerStatefulWidget {
  const QuickAssessmentScreen({super.key});

  @override
  ConsumerState<QuickAssessmentScreen> createState() => _QuickAssessmentScreenState();
}

class _QuickAssessmentScreenState extends ConsumerState<QuickAssessmentScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsControllerProvider).trackScreenView('quick_assessment');
      ref.read(analyticsControllerProvider).trackQuickAssessmentStart();
    });
  }

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      id: 'experience',
      question: 'How long have you been playing padel?',
      options: [
        QuizOption(id: 'new', text: 'Just starting / Never played', points: 1),
        QuizOption(id: 'months', text: 'A few months', points: 2),
        QuizOption(id: 'year', text: 'About a year', points: 3),
        QuizOption(id: 'years', text: '2+ years', points: 4),
        QuizOption(id: 'expert', text: '5+ years', points: 5),
      ],
    ),
    QuizQuestion(
      id: 'technique',
      question: 'How would you rate your shot technique?',
      options: [
        QuizOption(id: 'learning', text: 'Still learning basic shots', points: 1),
        QuizOption(id: 'basic', text: 'Can hit basic shots consistently', points: 2),
        QuizOption(id: 'good', text: 'Good control of most shots', points: 3),
        QuizOption(id: 'excellent', text: 'Excellent technique and variety', points: 4),
        QuizOption(id: 'master', text: 'Master level technique', points: 5),
      ],
    ),
    QuizQuestion(
      id: 'strategy',
      question: 'How well do you understand padel strategy?',
      options: [
        QuizOption(id: 'basic', text: 'Just hitting the ball back', points: 1),
        QuizOption(id: 'some', text: 'Know some basic tactics', points: 2),
        QuizOption(id: 'good', text: 'Good understanding of positioning', points: 3),
        QuizOption(id: 'advanced', text: 'Advanced tactical awareness', points: 4),
        QuizOption(id: 'expert', text: 'Expert strategic thinking', points: 5),
      ],
    ),
    QuizQuestion(
      id: 'walls',
      question: 'How comfortable are you playing off the walls?',
      options: [
        QuizOption(id: 'avoid', text: 'Try to avoid wall shots', points: 1),
        QuizOption(id: 'basic', text: 'Can handle simple wall returns', points: 2),
        QuizOption(id: 'comfortable', text: 'Comfortable with wall play', points: 3),
        QuizOption(id: 'advanced', text: 'Use walls strategically', points: 4),
        QuizOption(id: 'master', text: 'Master of all wall angles', points: 5),
      ],
    ),
    QuizQuestion(
      id: 'competition',
      question: 'What level of competition do you usually play?',
      options: [
        QuizOption(id: 'casual', text: 'Casual games with friends', points: 1),
        QuizOption(id: 'club', text: 'Club level matches', points: 2),
        QuizOption(id: 'local', text: 'Local tournaments', points: 3),
        QuizOption(id: 'regional', text: 'Regional competitions', points: 4),
        QuizOption(id: 'professional', text: 'Professional level', points: 5),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Quick Skill Assessment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Question
                  Text(
                    currentQuestion.question,
                    style: AppTypography.h2,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  
                  // Options
                  Expanded(
                    child: ListView.separated(
                      itemCount: currentQuestion.options.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final option = currentQuestion.options[index];
                        final isSelected = _answers[currentQuestion.id] == option.id;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _answers[currentQuestion.id] = option.id;
                            });
                            
                            // Track question answered
                            ref.read(analyticsControllerProvider).trackQuizQuestionAnswered(
                              _currentQuestionIndex + 1,
                              option.text,
                              option.points,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlue : AppColors.grey200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: AppShadows.small,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppColors.primaryBlue : AppColors.white,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: AppColors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _currentQuestionIndex--;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              side: const BorderSide(color: AppColors.grey300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      
                      if (_currentQuestionIndex > 0) const SizedBox(width: AppSpacing.lg),
                      
                      Expanded(
                        flex: _currentQuestionIndex == 0 ? 1 : 2,
                        child: ElevatedButton(
                          onPressed: _answers[currentQuestion.id] != null
                              ? () => _handleNext()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                  ),
                                )
                              : Text(
                                  _currentQuestionIndex == _questions.length - 1 ? 'Complete Assessment' : 'Next',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeAssessment();
    }
  }

  Future<void> _completeAssessment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate total score
      int totalScore = 0;
      for (final question in _questions) {
        final answerId = _answers[question.id];
        final option = question.options.firstWhere((opt) => opt.id == answerId);
        totalScore += option.points;
      }

      // Determine skill level based on score
      SkillLevel computedLevel;
      if (totalScore <= 10) {
        computedLevel = SkillLevel.beginner;
      } else if (totalScore <= 18) {
        computedLevel = SkillLevel.intermediate;
      } else {
        computedLevel = SkillLevel.advanced;
      }

      // Update user skill
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        final previousSkillLevel = user.skill.effectiveLevel?.displayName ?? 'none';
        
        await ref.read(authControllerProvider.notifier).updateUserSkill(
          UserSkill(
            quizScore: totalScore,
            computedLevel: computedLevel,
          ),
        );
        
        // Track assessment completion
        ref.read(analyticsControllerProvider).trackQuickAssessmentComplete(
          totalScore,
          computedLevel.displayName,
          previousSkillLevel,
        );
      }

      if (mounted) {
        // Show result dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Assessment Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 48,
                  color: _getSkillLevelColor(computedLevel),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Your skill level: ${computedLevel.displayName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Score: $totalScore/25',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  computedLevel.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing assessment: $e'),
            backgroundColor: AppColors.error,
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

  Color _getSkillLevelColor(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return AppColors.success;
      case SkillLevel.intermediate:
        return AppColors.warning;
      case SkillLevel.advanced:
        return AppColors.error;
    }
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<QuizOption> options;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class QuizOption {
  final String id;
  final String text;
  final int points;

  QuizOption({
    required this.id,
    required this.text,
    required this.points,
  });
}