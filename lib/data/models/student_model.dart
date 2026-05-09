class StudentModel {
  final String id;
  final String name;
  final String email;
  final String branch;
  final int year; // 1-4
  final String targetCareer;
  final List<String> skills;
  final int careerScore;
  final List<String> earnedBadges;
  final int questionsAsked;
  final int mentorSessionsAttended;
  final String photoUrl;
  final String rollNumber;
  final String mobileNumber;
  final String? resumeUrl;
  final bool isVerified;
  final DateTime? createdAt;

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
    required this.mobileNumber,
    this.resumeUrl,
    this.isVerified = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'branch': branch,
      'year': year,
      'targetCareer': targetCareer,
      'skills': skills,
      'careerScore': careerScore,
      'earnedBadges': earnedBadges,
      'questionsAsked': questionsAsked,
      'mentorSessionsAttended': mentorSessionsAttended,
      'photoUrl': photoUrl,
      'rollNumber': rollNumber,
      'mobileNumber': mobileNumber,
      'resumeUrl': resumeUrl,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      branch: map['branch'] ?? '',
      year: map['year'] ?? 1,
      targetCareer: map['targetCareer'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      careerScore: map['careerScore'] ?? 0,
      earnedBadges: List<String>.from(map['earnedBadges'] ?? []),
      questionsAsked: map['questionsAsked'] ?? 0,
      mentorSessionsAttended: map['mentorSessionsAttended'] ?? 0,
      photoUrl: map['photoUrl'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      resumeUrl: map['resumeUrl'],
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}
