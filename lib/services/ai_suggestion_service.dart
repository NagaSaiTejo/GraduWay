import '../data/models/student_model.dart';
import '../data/models/alumni_model.dart';

class AISuggestionService {
  /// Simple keyword-based matching algorithm to simulate AI suggestions.
  /// It compares student skills and target career with alumni skills and industry.
  static List<AlumniModel> getSuggestions(StudentModel student, List<AlumniModel> allAlumni) {
    if (allAlumni.isEmpty) return [];

    // Calculate score for each alumni
    final scoredAlumni = allAlumni.map((alumni) {
      double score = 0;

      // 1. Match skills (High weight)
      final studentSkills = student.skills.map((s) => s.toLowerCase()).toSet();
      final alumniSkills = alumni.skills.map((s) => s.toLowerCase()).toSet();

      if (studentSkills.isNotEmpty) {
        final skillMatches = studentSkills.intersection(alumniSkills).length;
        score += skillMatches * 10;
      }

      // 2. Match Target Career vs Alumni Role/Company (Medium weight)
      if (student.targetCareer.isNotEmpty) {
        final target = student.targetCareer.toLowerCase();
        if (alumni.role.toLowerCase().contains(target) ||
            alumni.company.toLowerCase().contains(target) ||
            alumni.targetRole.toLowerCase().contains(target)) {
          score += 15;
        }
      }

      // 3. Same branch (Bonus)
      if (student.branch == alumni.branch && student.branch.isNotEmpty) {
        score += 5;
      }

      // 4. Alumni Rating (Quality factor)
      score += alumni.rating * 2;

      return _ScoredAlumni(alumni, score);
    }).toList();

    // Filter out those with very low scores (e.g., only rating and nothing else matching)
    // For a meaningful suggestion, we want at least one keyword match or branch match.
    final filteredAlumni = scoredAlumni.where((sa) {
       // Must have at least a skill match, career match, or branch match to be suggested
       // (Rating alone is not enough for "suggestion")
       return sa.score > (sa.alumni.rating * 2);
    }).toList();

    // Sort by score descending and take top 5
    filteredAlumni.sort((a, b) => b.score.compareTo(a.score));

    return filteredAlumni
        .map((sa) => sa.alumni)
        .take(5)
        .toList();
  }
}

class _ScoredAlumni {
  final AlumniModel alumni;
  final double score;
  _ScoredAlumni(this.alumni, this.score);
}
