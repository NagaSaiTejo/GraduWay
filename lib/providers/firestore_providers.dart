import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/alumni_model.dart';
import '../data/models/models.dart';
import '../data/mock/alumni_data.dart';
import '../data/mock/placement_data.dart';

// ─── Alumni from Firestore ────────────────────────────────────────────────────
/// Real-time alumni stream from Firestore.
/// Falls back to mock data if Firestore is unavailable (dev mode).
final alumniStreamProvider = StreamProvider<List<AlumniModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('alumni')
      .where('isVerified', isEqualTo: true)
      .orderBy('rating', descending: true)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return mockAlumni; // dev fallback
    return snapshot.docs.map((doc) => AlumniModel.fromFirestore(doc)).toList();
  }).handleError((_) => mockAlumni);
});

// ─── Q&A from Firestore ──────────────────────────────────────────────────────
/// Real-time Q&A stream from Firestore.
/// Falls back to mockQA in development when Firebase is not configured.
final qaStreamProvider = StreamProvider<List<QAModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('qa')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return mockQA; // dev fallback
    return snapshot.docs.map((doc) => QAModel.fromFirestore(doc)).toList();
  }).handleError((_) => mockQA);
});

// ─── Placement Statistics via Cloud Functions ────────────────────────────────
/// Placement statistics via Firebase Cloud Functions.
/// Falls back to realistic mock stats if functions are not deployed.
final placementStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('getPlacementStats')
        .call();
    return result.data as Map<String, dynamic>;
  } catch (e) {
    // Graceful fallback — realistic Aditya College data
    return {
      'totalAlumni': 450,
      'companiesRepresented': 120,
      'avgPackage': 12.5,
      'placementRate': 94,
      'topRecruiters': {
        'Amazon': 12,
        'Microsoft': 8,
        'Zoho': 25,
        'TCS': 45,
        'Infosys': 38,
        'Freshworks': 11,
      },
      'batchWiseAvg': {
        '2024': 11.2,
        '2023': 10.8,
        '2022': 9.4,
        '2021': 8.7,
      },
    };
  }
});

// ─── Placement Analytics from Firestore ──────────────────────────────────────
final placementDataProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('placement_analytics')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    // Fallback to empty list
    return [];
  }
});

// ─── Mentorship Requests ─────────────────────────────────────────────────────
/// Real-time mentorship requests for the current student.
final mentorshipRequestsProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, studentId) {
  return FirebaseFirestore.instance
      .collection('mentorship_requests')
      .where('studentId', isEqualTo: studentId)
      .orderBy('requestedAt', descending: true)
      .snapshots();
});

// ─── Events from Firestore ──────────────────────────────────────────────────
/// Real-time events stream.
/// Falls back to mockEvents when Firestore is not available.
final eventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('events')
      .orderBy('eventDate', descending: false)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return mockEvents; // dev fallback
    return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }).handleError((_) => mockEvents);
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
