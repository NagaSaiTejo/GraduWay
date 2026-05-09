import 'package:flutter_test/flutter_test.dart';
import 'package:graduway/data/models/student_model.dart';
import 'package:graduway/data/models/alumni_model.dart';
import 'package:graduway/services/ai_suggestion_service.dart';

void main() {
  group('AISuggestionService Tests', () {
    const student = StudentModel(
      id: 's1',
      name: 'Test Student',
      email: 'test@aec.edu.in',
      branch: 'CSE',
      year: 3,
      targetCareer: 'Google',
      skills: ['Flutter', 'Dart', 'Python'],
      careerScore: 0,
      earnedBadges: [],
      questionsAsked: 0,
      mentorSessionsAttended: 0,
      photoUrl: '',
      rollNumber: '123',
      mobileNumber: '1234567890',
    );

    final alumniList = [
      const AlumniModel(
        id: 'a1',
        name: 'Matching Alumni',
        batch: '2020',
        branch: 'CSE',
        company: 'Google',
        role: 'Software Engineer',
        location: 'Hyderabad',
        package: 20,
        skills: ['Flutter', 'Go'],
        photoUrl: '',
        advice: '',
        story: '',
        linkedIn: '',
        isVerified: true,
        menteeCount: 0,
        rating: 5.0,
        anonConfession: '',
        interviewRounds: [],
        targetRole: '',
        email: 'a1@alum.com',
        yearsOfExp: 4,
      ),
      const AlumniModel(
        id: 'a2',
        name: 'Non-Matching Alumni',
        batch: '2018',
        branch: 'MECH',
        company: 'Tata Motors',
        role: 'Mechanical Engineer',
        location: 'Pune',
        package: 8,
        skills: ['AutoCAD'],
        photoUrl: '',
        advice: '',
        story: '',
        linkedIn: '',
        isVerified: true,
        menteeCount: 0,
        rating: 4.0,
        anonConfession: '',
        interviewRounds: [],
        targetRole: '',
        email: 'a2@alum.com',
        yearsOfExp: 6,
      ),
    ];

    test('should suggest alumni with matching skills and target career', () {
      final suggestions = AISuggestionService.getSuggestions(student, alumniList);

      expect(suggestions, isNotEmpty);
      expect(suggestions.first.name, 'Matching Alumni');
    });

    test('should return empty if no keyword or branch matches', () {
      const mechanicStudent = StudentModel(
        id: 's2',
        name: 'Mech Student',
        email: 'm@aec.edu.in',
        branch: 'MECH',
        year: 2,
        targetCareer: '',
        skills: ['Swimming'],
        careerScore: 0,
        earnedBadges: [],
        questionsAsked: 0,
        mentorSessionsAttended: 0,
        photoUrl: '',
        rollNumber: '456',
        mobileNumber: '123',
      );

      // Matching Alumni is CSE/Google, mechanicStudent is MECH/Swimming/No Target.
      // Rating 5.0 * 2 = 10 score, which should be filtered out by logic sa.score > alumni.rating * 2
      final suggestions = AISuggestionService.getSuggestions(mechanicStudent, [alumniList[0]]);
      expect(suggestions, isEmpty);
    });
  });
}
