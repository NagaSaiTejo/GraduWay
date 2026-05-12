import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/alumni_model.dart';
import '../data/models/models.dart';
import '../data/mock/placement_data.dart';
import '../data/mock/alumni_data.dart';

/// Helper to check if Firebase is initialized before accessing services.
/// This prevents [core/no-app] errors when running in local/dev mode without keys.
bool _isFirebaseReady() {
  try {
    Firebase.app();
    return true;
  } catch (_) {
    return false;
  }
}

// ─── Alumni from Firestore ────────────────────────────────────────────────────
/// Real-time alumni stream from Firestore.
/// - Firebase NOT configured (dev/CI): returns mock data so UI is testable.
/// - Firebase configured but collection empty or error: returns [] so the UI
///   shows a genuine empty/error state rather than seeded mock content.
final alumniStreamProvider = StreamProvider<List<AlumniModel>>((ref) {
  if (!_isFirebaseReady()) return Stream.value(mockAlumni);

  return FirebaseFirestore.instance
      .collection('alumni')
      .where('isVerified', isEqualTo: true)
      .orderBy('rating', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => AlumniModel.fromFirestore(doc)).toList())
      .handleError((Object _) => <AlumniModel>[]);
});

// ─── Q&A from Firestore ──────────────────────────────────────────────────────
/// Real-time Q&A stream from Firestore.
/// - Firebase NOT configured (dev/CI): returns mockQA so UI is testable.
/// - Firebase configured: returns live data; returns [] on error (not mock).
final qaStreamProvider = StreamProvider<List<QAModel>>((ref) {
  if (!_isFirebaseReady()) return Stream.value(mockQA);

  return FirebaseFirestore.instance
      .collection('qa')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => QAModel.fromFirestore(doc)).toList())
      .handleError((Object _) => <QAModel>[]);
});

// ─── Placement Statistics via Cloud Functions ────────────────────────────────
/// Placement statistics via Firebase Cloud Functions.
/// Falls back to realistic mock stats if functions are not deployed.
final placementStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  if (!_isFirebaseReady()) return _mockPlacementStats();

  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('getPlacementStats')
        .call();
    return result.data as Map<String, dynamic>;
  } catch (e) {
    return _mockPlacementStats();
  }
});

Map<String, dynamic> _mockPlacementStats() => {
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

// ─── Placement Analytics from Firestore ──────────────────────────────────────
final placementDataProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (!_isFirebaseReady()) return [];

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('placement_analytics')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    return [];
  }
});

// ─── Mentorship Requests ─────────────────────────────────────────────────────
/// Real-time mentorship requests for the current student.
final mentorshipRequestsProvider =
    StreamProvider.family<QuerySnapshot?, String>((ref, studentId) {
  if (!_isFirebaseReady()) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('mentorship_requests')
      .where('studentId', isEqualTo: studentId)
      .orderBy('requestedAt', descending: true)
      .snapshots();
});

// ─── Events from Firestore ──────────────────────────────────────────────────
/// Real-time events stream with Firestore as the primary source.
/// - Firebase NOT configured (dev/CI): falls back to mockEvents.
/// - Firebase configured: streams live data; returns [] on error (not mock).
final eventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  if (!_isFirebaseReady()) return Stream.value(mockEvents);

  return FirebaseFirestore.instance
      .collection('events')
      .orderBy('eventDate', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return EventModel(
              id: doc.id,
              title: data['title'] as String? ?? '',
              description: data['description'] as String? ?? '',
              hostAlumniName: data['hostAlumniName'] as String? ?? '',
              hostCompany: data['hostCompany'] as String? ?? '',
              eventDate:
                  (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
              type: data['type'] as String? ?? 'webinar',
              registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
              isRsvped: data['isRsvped'] as bool? ?? false,
            );
          }).toList())
      .handleError((Object _) => <EventModel>[]);
});

// ─── Notifications ───────────────────────────────────────────────────────────

final notificationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  if (!_isFirebaseReady()) return Stream.value([]);

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
  if (!_isFirebaseReady()) return Stream.value(0);

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});
