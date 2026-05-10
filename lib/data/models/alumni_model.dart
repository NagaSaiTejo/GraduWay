import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Create an [AlumniModel] from a Firestore document snapshot.
  factory AlumniModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlumniModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      batch: data['passoutYear']?.toString() ?? '',
      branch: data['branch'] as String? ?? '',
      company: data['company'] as String? ?? '',
      role: data['jobRole'] as String? ?? '',
      location: data['location'] as String? ?? '',
      package: (data['package'] as num?)?.toDouble() ?? 0.0,
      skills: List<String>.from(data['skills'] as List? ?? []),
      photoUrl: data['profileImageUrl'] as String? ?? '',
      advice: data['advice'] as String? ?? '',
      story: data['story'] as String? ?? '',
      linkedIn: data['linkedIn'] as String? ?? '',
      isVerified: data['isVerified'] as bool? ?? false,
      menteeCount: (data['menteeCount'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      anonConfession: data['anonConfession'] as String? ?? '',
      interviewRounds:
          List<String>.from(data['interviewRounds'] as List? ?? []),
      targetRole: data['targetRole'] as String? ?? '',
      email: data['email'] as String? ?? '',
      yearsOfExp: (data['yearsOfExp'] as num?)?.toInt() ?? 0,
    );
  }

  /// Create an [AlumniModel] from a plain Map (MongoDB/REST API response).
  factory AlumniModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return AlumniModel(
      id: id ?? data['id'] as String? ?? data['_id']?.toString() ?? '',
      name: data['name'] as String? ?? '',
      batch: data['passoutYear']?.toString() ?? '',
      branch: data['branch'] as String? ?? '',
      company: data['company'] as String? ?? '',
      role: data['jobRole'] as String? ?? '',
      location: data['location'] as String? ?? '',
      package: (data['package'] as num?)?.toDouble() ?? 0.0,
      skills: List<String>.from(data['skills'] as List? ?? []),
      photoUrl: data['profileImageUrl'] as String? ?? '',
      advice: data['advice'] as String? ?? '',
      story: data['story'] as String? ?? '',
      linkedIn: data['linkedIn'] as String? ?? '',
      isVerified: data['isVerified'] as bool? ?? false,
      menteeCount: (data['menteeCount'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      anonConfession: data['anonConfession'] as String? ?? '',
      interviewRounds:
          List<String>.from(data['interviewRounds'] as List? ?? []),
      targetRole: data['targetRole'] as String? ?? '',
      email: data['email'] as String? ?? '',
      yearsOfExp: (data['yearsOfExp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'passoutYear': batch,
      'branch': branch,
      'company': company,
      'jobRole': role,
      'location': location,
      'package': package,
      'skills': skills,
      'profileImageUrl': photoUrl,
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
    };
  }
}
