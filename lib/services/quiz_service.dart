import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/onboarding_models.dart';
import '../models/user_model.dart';

/// Service for handling skill quiz operations
class QuizService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get all quiz questions
  static List<QuizQuestion> getQuizQuestions() {
    return [
      const QuizQuestion(
        id: 'volleys',
        question: 'How comfortable are you with volleys?',
        description: 'Hitting the ball before it bounces',
        options: [
          QuizOption(text: 'I\'m just learning volleys', score: 1),
          QuizOption(text: 'I can volley sometimes', score: 2),
          QuizOption(text: 'I volley consistently', score: 3),
          QuizOption(text: 'I volley with good placement', score: 4),
          QuizOption(text: 'I master volley technique', score: 5),
        ],
      ),
      const QuizQuestion(
        id: 'walls',
        question: 'How well do you use the walls?',
        description: 'Playing off glass and back walls effectively',
        options: [
          QuizOption(text: 'Walls confuse me', score: 1),
          QuizOption(text: 'I can hit basic wall shots', score: 2),
          QuizOption(text: 'I use walls defensively', score: 3),
          QuizOption(text: 'I use walls strategically', score: 4),
          QuizOption(text: 'I master wall play', score: 5),
        ],
      ),
      const QuizQuestion(
        id: 'serve_return',
        question: 'How consistent are your serves and returns?',
        description: 'Starting points effectively',
        options: [
          QuizOption(text: 'Often miss serves/returns', score: 1),
          QuizOption(text: 'Get most serves/returns in', score: 2),
          QuizOption(text: 'Consistent serves/returns', score: 3),
          QuizOption(text: 'Varied serves/returns', score: 4),
          QuizOption(text: 'Strategic serves/returns', score: 5),
        ],
      ),
      const QuizQuestion(
        id: 'positioning',
        question: 'How well do you position yourself on court?',
        description: 'Court awareness and teamwork',
        options: [
          QuizOption(text: 'Still learning positioning', score: 1),
          QuizOption(text: 'Basic court awareness', score: 2),
          QuizOption(text: 'Good court positioning', score: 3),
          QuizOption(text: 'Excellent teamwork', score: 4),
          QuizOption(text: 'Advanced court strategy', score: 5),
        ],
      ),
      const QuizQuestion(
        id: 'experience',
        question: 'How much padel experience do you have?',
        description: 'Time playing and match experience',
        options: [
          QuizOption(text: 'Less than 3 months', score: 1),
          QuizOption(text: '3-6 months playing', score: 2),
          QuizOption(text: '6 months - 1 year', score: 3),
          QuizOption(text: '1-2 years playing', score: 4),
          QuizOption(text: 'More than 2 years', score: 5),
        ],
      ),
    ];
  }

  /// Calculate skill level from quiz responses
  static SkillLevel calculateSkillLevel(List<QuizResponse> responses) {
    if (responses.length != 5) {
      throw ArgumentError('Quiz must have exactly 5 responses');
    }

    final totalScore = responses.fold<int>(
      0,
      (sum, response) => sum + response.selectedScore,
    );

    // Score mapping: 5-25 total possible
    if (totalScore >= 5 && totalScore <= 9) {
      return SkillLevel.beginner;
    } else if (totalScore >= 10 && totalScore <= 17) {
      return SkillLevel.intermediate;
    } else if (totalScore >= 18 && totalScore <= 25) {
      return SkillLevel.advanced;
    } else {
      throw ArgumentError('Invalid total score: $totalScore');
    }
  }

  /// Process quiz completion
  static Future<QuizResult> processQuizCompletion({
    required List<QuizResponse> responses,
    required String userId,
  }) async {
    try {
      if (responses.length != 5) {
        throw ArgumentError('Quiz must have exactly 5 responses');
      }

      final totalScore = responses.fold<int>(
        0,
        (sum, response) => sum + response.selectedScore,
      );

      final computedLevel = calculateSkillLevel(responses);
      
      final result = QuizResult(
        responses: responses,
        totalScore: totalScore,
        computedLevel: computedLevel.name,
        completedAt: DateTime.now(),
      );

      // Log quiz completion analytics
      await _analytics.logEvent(
        name: 'quiz_completed',
        parameters: {
          'user_id': userId,
          'total_score': totalScore,
          'computed_level': computedLevel.name,
          'percentage_score': result.percentageScore.round(),
        },
      );

      // Log individual question responses
      for (final response in responses) {
        await _analytics.logEvent(
          name: 'quiz_question_answered',
          parameters: {
            'user_id': userId,
            'question_id': response.questionId,
            'selected_score': response.selectedScore,
            'selected_text': response.selectedText,
          },
        );
      }

      return result;
    } catch (e) {
      await _analytics.logEvent(
        name: 'quiz_error',
        parameters: {
          'user_id': userId,
          'error': e.toString(),
        },
      );
      
      throw Exception('Failed to process quiz: $e');
    }
  }

  /// Get skill level description
  static String getSkillLevelDescription(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'Perfect for learning the basics! You\'ll be matched with other beginners and have access to fundamental training resources.';
      case SkillLevel.intermediate:
        return 'Great foundation! You\'ll play with players who know the fundamentals and are working on strategy and consistency.';
      case SkillLevel.advanced:
        return 'Excellent skills! You\'ll be matched with experienced players for competitive and strategic matches.';
    }
  }

  /// Get recommended next steps for skill level
  static List<String> getSkillLevelRecommendations(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return [
          'Focus on basic shots: forehand, backhand, and serve',
          'Practice hitting the ball cleanly',
          'Learn court positioning basics',
          'Start with friendly matches to build confidence',
        ];
      case SkillLevel.intermediate:
        return [
          'Work on volley technique and placement',
          'Practice using walls defensively',
          'Improve serve variety and returns',
          'Focus on court positioning and teamwork',
        ];
      case SkillLevel.advanced:
        return [
          'Master advanced wall play and rebounds',
          'Develop strategic serves and attacking shots',
          'Perfect court positioning and communication',
          'Compete in tournaments and challenging matches',
        ];
    }
  }

  /// Validate quiz response
  static bool isValidQuizResponse(QuizResponse response) {
    final questions = getQuizQuestions();
    final question = questions.firstWhere(
      (q) => q.id == response.questionId,
      orElse: () => throw ArgumentError('Invalid question ID: ${response.questionId}'),
    );

    // Check if score is within valid range for the question
    final validScores = question.options.map((o) => o.score).toList();
    return validScores.contains(response.selectedScore);
  }

  /// Validate all quiz responses
  static bool areValidQuizResponses(List<QuizResponse> responses) {
    if (responses.length != 5) return false;
    
    try {
      return responses.every(isValidQuizResponse);
    } catch (e) {
      return false;
    }
  }

  /// Get quiz progress percentage
  static double getQuizProgress(List<QuizResponse> responses) {
    return (responses.length / 5.0).clamp(0.0, 1.0);
  }

  /// Check if quiz is complete
  static bool isQuizComplete(List<QuizResponse> responses) {
    return responses.length == 5 && areValidQuizResponses(responses);
  }

  /// Get question by ID
  static QuizQuestion? getQuestionById(String questionId) {
    final questions = getQuizQuestions();
    try {
      return questions.firstWhere((q) => q.id == questionId);
    } catch (e) {
      return null;
    }
  }

  /// Create UserSkill from quiz result
  static UserSkill createUserSkillFromQuiz(QuizResult quizResult) {
    final computedLevel = SkillLevel.values.firstWhere(
      (level) => level.name == quizResult.computedLevel,
    );

    return UserSkill(
      quizScore: quizResult.totalScore,
      computedLevel: computedLevel,
      userOverrideLevel: null, // No override initially
    );
  }

  /// Get quiz statistics (for admin/analytics)
  static Map<String, dynamic> getQuizStatistics(List<QuizResponse> responses) {
    if (responses.isEmpty) {
      return {
        'total_responses': 0,
        'average_score': 0.0,
        'completion_rate': 0.0,
      };
    }

    final totalScore = responses.fold<int>(
      0,
      (sum, response) => sum + response.selectedScore,
    );

    return {
      'total_responses': responses.length,
      'total_score': totalScore,
      'average_score': totalScore / responses.length,
      'completion_rate': responses.length / 5.0,
      'is_complete': responses.length == 5,
    };
  }
}