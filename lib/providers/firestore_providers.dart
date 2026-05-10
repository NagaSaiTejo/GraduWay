import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/alumni_model.dart';
import '../data/models/models.dart';

// ─── Alumni from Firestore ────────────────────────────────────────────────────

final alumniStreamProvider = StreamProvider<List<AlumniModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('alumni')
      .where('isVerified', isEqualTo: true)
      .orderBy('rating', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => AlumniModel.fromFirestore(doc)).toList());
});

// ─── Q&A from Firestore ──────────────────────────────────────────────────────

final qaStreamProvider = StreamProvider<List<QAModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('qa')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => QAModel.fromFirestore(doc)).toList());
});

// ─── Placement Analytics from Firestore ─────────────────────────────────────

final placementDataProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final snapshot =
      await FirebaseFirestore.instance.collection('placement_analytics').get();
  return snapshot.docs.map((doc) => doc.data()).toList();
});

// ─── Mentorship Requests ─────────────────────────────────────────────────────

final mentorshipRequestsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, studentId) {
  return FirebaseFirestore.instance
      .collection('mentorship_requests')
      .where('studentId', isEqualTo: studentId)
      .orderBy('requestedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList());
});

// ─── Notifications ───────────────────────────────────────────────────────────

final notificationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList());
});

// ─── Unread notification count ───────────────────────────────────────────────

final unreadNotificationsCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});
