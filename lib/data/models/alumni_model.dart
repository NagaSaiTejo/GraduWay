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
  final String targetRole;
  final String email;
  final int yearsOfExp;
  final String? idCardUrl;
  final DateTime? createdAt;

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
    this.idCardUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'batch': batch,
      'branch': branch,
      'company': company,
      'role': role,
      'location': location,
      'package': package,
      'skills': skills,
      'photoUrl': photoUrl,
      'advice': advice,
      'story': story,
      'linkedIn': linkedIn,
      'isVerified': isVerified,
      'menteeCount': menteeCount,
      'rating': rating,
      'anonConfession': anonConfession,
      'interviewRounds': interviewRounds,
      'targetRole': targetRole,
      'email': email,
      'yearsOfExp': yearsOfExp,
      'idCardUrl': idCardUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AlumniModel.fromMap(Map<String, dynamic> map) {
    return AlumniModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      batch: map['batch'] ?? '',
      branch: map['branch'] ?? '',
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      location: map['location'] ?? '',
      package: (map['package'] ?? 0.0).toDouble(),
      skills: List<String>.from(map['skills'] ?? []),
      photoUrl: map['photoUrl'] ?? '',
      advice: map['advice'] ?? '',
      story: map['story'] ?? '',
      linkedIn: map['linkedIn'] ?? '',
      isVerified: map['isVerified'] ?? false,
      menteeCount: map['menteeCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      anonConfession: map['anonConfession'] ?? '',
      interviewRounds: List<String>.from(map['interviewRounds'] ?? []),
      targetRole: map['targetRole'] ?? '',
      email: map['email'] ?? '',
      yearsOfExp: map['yearsOfExp'] ?? 0,
      idCardUrl: map['idCardUrl'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}
