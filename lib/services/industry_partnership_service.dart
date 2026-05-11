/// Industry Partnership Service - GraduWay Phase 3
///
/// Structural foundation for alumni hiring managers to post
/// exclusive referral opportunities to GraduWay students.
///
/// Phase 3 Architecture:
/// - Alumni hiring managers get a "Partnership" badge on their profile
/// - They can post structured referral opportunities to Firestore
/// - Students see exclusive "Referral Available" tag on alumni profiles
/// - Application tracking via Firestore subcollection
///
/// Current: Data model + Firestore paths defined
/// Phase 3: Full UI in alumni_home_screen.dart + student notifications
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// A referral opportunity posted by an alumni hiring manager
class ReferralOpportunity {
  final String id;
  final String alumniId;
  final String alumniName;
  final String company;
  final String role;
  final String description;
  final List<String> requiredSkills;
  final String targetBranch; // 'All', 'CSE', 'ECE', etc.
  final int targetYear; // minimum year (1-4)
  final DateTime postedAt;
  final DateTime expiresAt;
  final bool isActive;
  final int applicantCount;
  final String firestorePath; // colleges/{collegeId}/referrals/{id}

  const ReferralOpportunity({
    required this.id,
    required this.alumniId,
    required this.alumniName,
    required this.company,
    required this.role,
    required this.description,
    required this.requiredSkills,
    required this.targetBranch,
    required this.targetYear,
    required this.postedAt,
    required this.expiresAt,
    required this.isActive,
    required this.applicantCount,
    required this.firestorePath,
  });

  factory ReferralOpportunity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferralOpportunity(
      id: doc.id,
      alumniId: data['alumniId'] as String? ?? '',
      alumniName: data['alumniName'] as String? ?? '',
      company: data['company'] as String? ?? '',
      role: data['role'] as String? ?? '',
      description: data['description'] as String? ?? '',
      requiredSkills: List<String>.from(data['requiredSkills'] as List? ?? []),
      targetBranch: data['targetBranch'] as String? ?? 'All',
      targetYear: (data['targetYear'] as num?)?.toInt() ?? 1,
      postedAt: (data['postedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as dynamic)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      isActive: data['isActive'] as bool? ?? true,
      applicantCount: (data['applicantCount'] as num?)?.toInt() ?? 0,
      firestorePath: doc.reference.path,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'alumniId': alumniId,
        'alumniName': alumniName,
        'company': company,
        'role': role,
        'description': description,
        'requiredSkills': requiredSkills,
        'targetBranch': targetBranch,
        'targetYear': targetYear,
        'postedAt': FieldValue.serverTimestamp(),
        'expiresAt': expiresAt,
        'isActive': isActive,
        'applicantCount': applicantCount,
      };
}

/// Service for managing industry referral partnerships
class IndustryPartnershipService {
  static final _db = FirebaseFirestore.instance;

  // Firestore collection path: per-college isolation
  static const String _collection = 'colleges/aditya_ec/referrals';

  /// Stream of active referral opportunities for a student
  static Stream<List<ReferralOpportunity>> getActiveReferrals({
    String branch = 'All',
    int studentYear = 1,
  }) {
    return _db
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ReferralOpportunity.fromFirestore(doc))
            .where((r) =>
                (r.targetBranch == 'All' || r.targetBranch == branch) &&
                studentYear >= r.targetYear)
            .toList());
  }

  /// Post a new referral opportunity (alumni only)
  static Future<void> postReferral(ReferralOpportunity opportunity) {
    return _db.collection(_collection).add(opportunity.toFirestore());
  }

  /// Apply for a referral opportunity
  static Future<void> applyForReferral({
    required String referralId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String resumeUrl,
  }) async {
    final batch = _db.batch();

    // Add application to subcollection
    final appRef =
        _db.collection('$_collection/$referralId/applications').doc(studentId);
    batch.set(appRef, {
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'resumeUrl': resumeUrl,
      'appliedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    // Increment applicant count
    final referralRef = _db.collection(_collection).doc(referralId);
    batch.update(referralRef, {
      'applicantCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Stream of applications for a specific referral (alumni view)
  static Stream<QuerySnapshot> getReferralApplications(String referralId) {
    return _db
        .collection('$_collection/$referralId/applications')
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }
}
