import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/radio_card.dart';
import '../../services/quiz_service.dart';
import '../../models/user_model.dart';
// import '../../models/onboarding_models.dart'; // Commented out for now

class QuizStep extends StatefulWidget {
  final VoidCallback onNext;
  
  const QuizStep({
    super.key,
    required this.onNext,
  });

  @override
  State<QuizStep> createState() => _QuizStepState();
}

class _QuizStepState extends State<QuizStep> {
  // final QuizService _quizService = QuizService();
  final PageController _pageController = PageController();
  
  // Simple questions for now
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'experience',
      'question': 'How long have you been playing padel?',
      'options': [
        {'text': 'I\'m completely new', 'score': 1},
        {'text': 'Less than 6 months', 'score': 2},
        {'text': '6 months to 2 years', 'score': 3},
        {'text': '2+ years', 'score': 4},
        {'text': '5+ years', 'score': 5},
      ]
    },
    {
      'id': 'skill',
      'question': 'How would you rate your overall skill?',
      'options': [
        {'text': 'Beginner', 'score': 1},
        {'text': 'Improving beginner', 'score': 2},
        {'text': 'Intermediate', 'score': 3},
        {'text': 'Advanced intermediate', 'score': 4},
        {'text': 'Advanced', 'score': 5},
      ]
    }
  ];
  
  Map<int, int> _answers = {};
  int _currentQuestionIndex = 0;
  bool _canSkip = true;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // _questions = _quizService.getQuizQuestions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            'What\'s your skill level?',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _canSkip 
              ? 'Answer a few questions to help us match you with players of similar level. You can skip this and set it later.'
              : 'Answer these questions to determine your skill level.',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            minHeight: 4,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          
          // Question content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              itemCount: _questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildQuestion(_questions[index], index);
              },
            ),
          ),
          
          // Navigation buttons
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              // Skip button (only on first question and if allowed)
              if (_currentQuestionIndex == 0 && _canSkip)
                Expanded(
                  child: TextButton(
                    onPressed: _skipQuiz,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    ),
                    child: const Text(
                      'Skip for Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              
              // Back button
              if (_currentQuestionIndex > 0 && (!_canSkip || _currentQuestionIndex > 0))
                Expanded(
                  child: TextButton(
                    onPressed: _previousQuestion,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              
              if (_currentQuestionIndex > 0 || !_canSkip)
                const SizedBox(width: AppSpacing.lg),
              
              // Next/Finish button
              Expanded(
                flex: _currentQuestionIndex == 0 && _canSkip ? 1 : 1,
                child: PrimaryButton(
                  text: _currentQuestionIndex == _questions.length - 1 
                    ? 'Complete Quiz' 
                    : 'Next',
                  onPressed: _canProceed() ? _nextQuestion : null,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question, int questionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        Text(
          question['question'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        
        // Options
        Expanded(
          child: ListView.separated(
            itemCount: question['options'].length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, optionIndex) {
              final option = question['options'][optionIndex];
              
              return RadioCard<int>(
                value: optionIndex,
                groupValue: _answers[questionIndex],
                title: option['text'],
                subtitle: '',
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _answers[questionIndex] = value ?? optionIndex;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  bool _canProceed() {
    return _answers.containsKey(_currentQuestionIndex);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.medium,
        curve: Curves.easeInOut,
      );
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: AppAnimations.medium,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipQuiz() {
    HapticFeedback.lightImpact();
    
    // Save skip status
    final quizData = {
      'isSkipped': true,
      'skillLevel': null,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // TODO: Save to onboarding state
    print('Quiz skipped: $quizData');
    
    widget.onNext();
  }

  Future<void> _completeQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      
      // Calculate simple score
      int totalScore = 0;
      for (var entry in _answers.entries) {
        final questionIndex = entry.key;
        final optionIndex = entry.value;
        totalScore += _questions[questionIndex]['options'][optionIndex]['score'] as int;
      }

      // Determine skill level
      String skillLevel;
      if (totalScore <= 4) {
        skillLevel = 'beginner';
      } else if (totalScore <= 7) {
        skillLevel = 'intermediate';
      } else {
        skillLevel = 'advanced';
      }
      
      // Save quiz data
      final quizData = {
        'isSkipped': false,
        'skillLevel': skillLevel,
        'score': totalScore,
        'answers': _answers,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // TODO: Save to onboarding state
      print('Quiz completed: $quizData');
      
      // Show result briefly
      await _showResult(skillLevel);
      
      widget.onNext();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showResult(String skillLevel) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'Your Skill Level',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: Icon(
                _getSkillIcon(skillLevel),
                size: 40,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              skillLevel.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _getSkillDescription(skillLevel),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            text: 'Continue',
            onPressed: () => Navigator.of(context).pop(),
            isLoading: false,
          ),
        ],
      ),
    );
  }

  IconData _getSkillIcon(String skillLevel) {
    switch (skillLevel) {
      case 'beginner':
        return Icons.star_outline;
      case 'intermediate':
        return Icons.star_half;
      case 'advanced':
        return Icons.star;
      default:
        return Icons.star_outline;
    }
  }
  
  String _getSkillDescription(String skillLevel) {
    switch (skillLevel) {
      case 'beginner':
        return 'New to padel or less than 6 months playing';
      case 'intermediate':
        return '6 months to 2 years, comfortable with basic shots';
      case 'advanced':
        return '2+ years, excellent technique and strategy';
      default:
        return 'Level assessment complete.';
    }
  }
}