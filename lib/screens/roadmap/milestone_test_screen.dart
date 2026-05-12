import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../core/api_config.dart';

class MilestoneTestScreen extends ConsumerStatefulWidget {
  final String roadmapName;
  final int milestoneIndex;

  const MilestoneTestScreen({
    super.key,
    required this.roadmapName,
    required this.milestoneIndex,
  });

  @override
  ConsumerState<MilestoneTestScreen> createState() =>
      _MilestoneTestScreenState();
}

class _MilestoneTestScreenState extends ConsumerState<MilestoneTestScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isSubmitted = false;
  bool _isSubmitting = false;
  String? _selectedAnswer;

  late final List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.roadmapName, widget.milestoneIndex);
  }

  // Generate 10 mock questions based on topic
  List<Map<String, dynamic>> _generateQuestions(String roadmap, int milestone) {
    final List<Map<String, dynamic>> questionBank = [
      {
        'question':
            'What is the primary language used to develop Flutter applications?',
        'options': ['Java', 'Kotlin', 'Dart', 'Swift'],
        'correctAnswer': 'Dart',
      },
      {
        'question':
            'Which widget is used to create a material design app in Flutter?',
        'options': ['CupertinoApp', 'MaterialApp', 'WidgetsApp', 'Scaffold'],
        'correctAnswer': 'MaterialApp',
      },
      {
        'question': 'What does state refer to in Flutter?',
        'options': [
          'The app lifecycle',
          'Data that can change over time',
          'The layout constraints',
          'Network requests'
        ],
        'correctAnswer': 'Data that can change over time',
      },
      {
        'question': 'Which of the following is a key feature of Flutter?',
        'options': ['Hot Reload', 'DOM manipulation', 'Virtual DOM', 'JSX'],
        'correctAnswer': 'Hot Reload',
      },
      {
        'question': 'What is the function of the pubspec.yaml file?',
        'options': [
          'Managing UI layouts',
          'Defining routing',
          'Managing dependencies',
          'Compiling code'
        ],
        'correctAnswer': 'Managing dependencies',
      },
      {
        'question': 'Which AWS service is used for scalable compute capacity?',
        'options': ['S3', 'EC2', 'RDS', 'Lambda'],
        'correctAnswer': 'EC2',
      },
      {
        'question': 'What does S3 stand for in AWS?',
        'options': [
          'Simple Storage Service',
          'Scalable Storage System',
          'Serverless Storage Solution',
          'Secure System Service'
        ],
        'correctAnswer': 'Simple Storage Service',
      },
      {
        'question': 'Which database type is DynamoDB?',
        'options': ['Relational', 'NoSQL', 'Graph', 'Time-series'],
        'correctAnswer': 'NoSQL',
      },
      {
        'question': 'In ServiceNow, what is an Incident?',
        'options': [
          'A planned change',
          'An unplanned interruption to an IT service',
          'A request for a new service',
          'A database record'
        ],
        'correctAnswer': 'An unplanned interruption to an IT service',
      },
      {
        'question': 'What is the primary role of a Load Balancer?',
        'options': [
          'Store data',
          'Distribute incoming network traffic',
          'Compile code',
          'Manage user authentication'
        ],
        'correctAnswer': 'Distribute incoming network traffic',
      },
      {
        'question': 'Which data structure uses LIFO?',
        'options': ['Queue', 'Stack', 'Tree', 'Graph'],
        'correctAnswer': 'Stack',
      },
      {
        'question': 'What is the time complexity of binary search?',
        'options': ['O(1)', 'O(n)', 'O(log n)', 'O(n^2)'],
        'correctAnswer': 'O(log n)',
      },
      {
        'question': 'What is REST an acronym for?',
        'options': [
          'Representational State Transfer',
          'Remote State Transmission',
          'Reliable Server Technology',
          'Relational State Transfer'
        ],
        'correctAnswer': 'Representational State Transfer',
      },
      {
        'question': 'Which HTTP method is used to create a new resource?',
        'options': ['GET', 'POST', 'PUT', 'DELETE'],
        'correctAnswer': 'POST',
      },
      {
        'question': 'What does CI/CD stand for?',
        'options': [
          'Continuous Integration / Continuous Deployment',
          'Code Integration / Code Deployment',
          'Constant Improvement / Constant Delivery',
          'Centralized Integration / Centralized Deployment'
        ],
        'correctAnswer': 'Continuous Integration / Continuous Deployment',
      }
    ];

    questionBank.shuffle();
    final selectedQuestions = questionBank.take(10).toList();

    // Shuffle options for each question
    for (var q in selectedQuestions) {
      final options = List<String>.from(q['options'] as List);
      options.shuffle();
      q['options'] = options;
    }

    return selectedQuestions;
  }

  void _nextQuestion() {
    if (_selectedAnswer == _questions[_currentQuestionIndex]['correctAnswer']) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      _submitTest();
    }
  }

  Future<void> _submitTest() async {
    setState(() {
      _isSubmitted = true;
      _isSubmitting = true;
    });

    final passed = _score >= 7; // 70% passing mark

    if (passed) {
      final authState = ref.read(authProvider);
      final email = authState.student?.email ?? authState.loginEmail;

      try {
        final response = await http.post(
          Uri.parse(ApiConfig.roadmapCompleteMilestone),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'roadmapName': widget.roadmapName,
            'newMilestoneIndex': widget.milestoneIndex + 1,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final progressMap = data['roadmapProgress'] as Map<String, dynamic>;
          ref.read(authProvider.notifier).updateRoadmapState(
                activeRoadmap: data['activeRoadmap'],
                roadmapProgress:
                    progressMap.map((k, v) => MapEntry(k, (v as num).toInt())),
                careerScore: data['careerScore'],
              );
        }
      } catch (e) {
        debugPrint('Error completing milestone: $e');
      }
    }

    try {
      FirebaseAnalytics.instance
          .logEvent(name: 'milestone_test_completed', parameters: {
        'roadmap': widget.roadmapName,
        'milestoneIndex': widget.milestoneIndex,
        'score': _score,
        'passed': passed ? 1 : 0,
      });
    } catch (_) {}

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildResultScreen();
    }

    final currentQ = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Milestone ${widget.milestoneIndex + 1} Test',
            style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_currentQuestionIndex + 1} of 10',
                style: const TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / 10,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 32),
            Text(currentQ['question'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ...currentQ['options'].map<Widget>((option) {
              final isSelected = _selectedAnswer == option;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedAnswer = option),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Text(option,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedAnswer == null ? null : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                    _currentQuestionIndex == 9
                        ? 'Submit Test'
                        : 'Next Question',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final passed = _score >= 7;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSubmitting)
                const CircularProgressIndicator()
              else ...[
                Icon(passed ? Icons.check_circle : Icons.cancel,
                    color: passed ? AppColors.success : AppColors.error,
                    size: 100),
                const SizedBox(height: 24),
                Text(passed ? 'Milestone Passed!' : 'Test Failed',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('You scored $_score out of 10.',
                    style: const TextStyle(
                        fontSize: 18, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Text(
                  passed
                      ? 'Your progress has been updated.'
                      : 'You need at least 7/10 to pass. Review the materials and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          passed ? AppColors.success : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Roadmap',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
