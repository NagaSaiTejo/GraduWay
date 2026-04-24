class AlumniModel {
  final String id;
  final String name;
  final String batch;
  final String branch;
  final String company;
  final String role;
  final String location;
  final double package; // LPA
  final List<String> skills;
  final String photoUrl;
  final String advice;
  final String story;
  final String linkedIn;
  final bool isVerified;
  final int menteeCount;
  final double rating;
  final String anonConfession;
  final List<String> interviewRounds;
  final String targetRole; // FAANG, Product, Service, Core, Higher Studies
  final String email;
  final int yearsOfExp;

  const AlumniModel({
    required this.id,
    required this.name,
    required this.batch,
    required this.branch,
    required this.company,
    required this.role,
    required this.location,
    required this.package,
    required this.skills,
    required this.photoUrl,
    required this.advice,
    required this.story,
    required this.linkedIn,
    required this.isVerified,
    required this.menteeCount,
    required this.rating,
    required this.anonConfession,
    required this.interviewRounds,
    required this.targetRole,
    required this.email,
    required this.yearsOfExp,
  });
}
