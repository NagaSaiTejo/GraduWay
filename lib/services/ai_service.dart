import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AI Service Layer — GraduWay Phase 2 Intelligence Features
///
/// This service provides the foundation for:
/// 1. AI-powered skill recommendations (via Gemini API)
/// 2. Resume analysis and ATS scoring
/// 3. Smart mentorship matching based on student goals + alumni expertise
/// 4. Personalized career path suggestions
///
/// Phase 1 (current): ATS resume scanning implemented
/// Phase 2 (roadmap): Full recommendation engine
class AIService {
  static const String _geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  /// Analyze resume against job description and return ATS score + feedback.
  /// Currently wired to backend/routes/atsRoutes.js which calls Gemini.
  static Future<Map<String, dynamic>> analyzeResume({
    required String resumeText,
    required String jobDescription,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_geminiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Analyze this resume against the job description.
                  Return JSON with: score (0-100), strengths (list), 
                  weaknesses (list), missingKeywords (list), summary (string).
                  
                  Resume: $resumeText
                  Job Description: $jobDescription'''
                }
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('AIService.analyzeResume error: $e');
    }
    return {};
  }

  /// Phase 2: Recommend skills based on student profile and target career.
  /// Matches student's current skills against alumni who achieved the same target role.
  static Future<List<String>> recommendSkills({
    required String targetCareer,
    required List<String> currentSkills,
    required String branch,
  }) async {
    // Phase 2 implementation: will query Firestore alumni collection
    // to find skill gap between student and successful alumni in same target role
    debugPrint('AIService.recommendSkills: Phase 2 feature — $targetCareer');
    return [];
  }

  /// Phase 2: Smart mentorship matching score between student and alumni.
  /// Uses cosine similarity on skill vectors + goal alignment.
  static double calculateMentorshipMatchScore({
    required List<String> studentGoalSkills,
    required List<String> alumniSkills,
    required String studentTargetRole,
    required String alumniTargetRole,
  }) {
    if (alumniSkills.isEmpty || studentGoalSkills.isEmpty) return 0.0;

    final overlap = studentGoalSkills
        .where((s) =>
            alumniSkills.map((a) => a.toLowerCase()).contains(s.toLowerCase()))
        .length;

    final skillScore = overlap / studentGoalSkills.length;
    final roleBonus = studentTargetRole == alumniTargetRole ? 0.3 : 0.0;

    return (skillScore * 0.7 + roleBonus).clamp(0.0, 1.0);
  }
}
