class StudentModel {
  final String id;
  final String name;
  final String email;
  final String branch;
  final int year; // 1-4
  final String targetCareer; // FAANG, Product, Service, Core, Higher Studies, Startup
  final List<String> skills;
  final int careerScore; // 0-100
  final List<String> earnedBadges;
  final int questionsAsked;
  final int mentorSessionsAttended;
  final String photoUrl;
  final String rollNumber;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.branch,
    required this.year,
    required this.targetCareer,
    required this.skills,
    required this.careerScore,
    required this.earnedBadges,
    required this.questionsAsked,
    required this.mentorSessionsAttended,
    required this.photoUrl,
    required this.rollNumber,
  });
}
