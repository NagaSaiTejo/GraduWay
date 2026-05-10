import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';

class MilestoneTestScreen extends ConsumerStatefulWidget {
  final String roadmapName;
  final int milestoneIndex;

  const MilestoneTestScreen({
    super.key,
    required this.roadmapName,
    required this.milestoneIndex,
  });

  @override
  ConsumerState<MilestoneTestScreen> createState() => _MilestoneTestScreenState();
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
    return List.generate(10, (i) {
      return {
        'question': 'Sample Question ${i + 1} for $roadmap Milestone ${milestone + 1}',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'correctAnswer': 'Option A', // Always A for mock purposes
      };
    });
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
      final email = ref.read(authProvider).loginEmail;
      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/api/roadmap/complete-milestone'),
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
            roadmapProgress: progressMap.map((k, v) => MapEntry(k, (v as num).toInt())),
            careerScore: data['careerScore'],
          );
        }
      } catch (e) {
        debugPrint('Error completing milestone: $e');
      }
    }

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
        title: Text('Milestone ${widget.milestoneIndex + 1} Test', style: const TextStyle(color: AppColors.textPrimary)),
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
              style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 32),
            Text(currentQ['question'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Text(option, style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_currentQuestionIndex == 9 ? 'Submit Test' : 'Next Question', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                Icon(passed ? Icons.check_circle : Icons.cancel, color: passed ? AppColors.success : AppColors.error, size: 100),
                const SizedBox(height: 24),
                Text(passed ? 'Milestone Passed!' : 'Test Failed', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('You scored $_score out of 10.', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Text(passed ? 'Your progress has been updated.' : 'You need at least 7/10 to pass. Review the materials and try again.',
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
                      backgroundColor: passed ? AppColors.success : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Roadmap', style: TextStyle(fontWeight: FontWeight.bold)),
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
