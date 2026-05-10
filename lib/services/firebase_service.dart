import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Central Firebase service layer for GraduWay.
/// Wraps Firestore, Auth, and Storage operations with a clean API.
class FirebaseService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  // ─── Authentication ──────────────────────────────────────────────────────

  /// Sign in with Firebase Auth — returns the role from Firestore 'users' doc.
  static Future<Map<String, dynamic>?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final userDoc = await db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return {'uid': uid, ...userDoc.data()!};
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth error: ${e.code} — ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('FirebaseService.signIn error: $e');
      rethrow;
    }
  }

  /// Register a new user in Firebase Auth AND Firestore.
  static Future<void> registerUser({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> userData,
  }) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    // Write to role-specific collection and unified 'users' collection
    await Future.wait([
      db.collection('users').doc(uid).set({
        'role': role,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        ...userData,
      }),
      db.collection(role == 'student' ? 'students' : role == 'alumni' ? 'alumni' : 'admins')
          .doc(uid)
          .set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        ...userData,
      }),
    ]);
  }

  static Future<void> signOut() => auth.signOut();

  static User? get currentUser => auth.currentUser;

  // ─── Alumni ─────────────────────────────────────────────────────────────

  /// Stream of all verified alumni profiles from Firestore.
  static Stream<QuerySnapshot> getAlumniStream() {
    return db
        .collection('alumni')
        .where('isVerified', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots();
  }

  /// Fetch all alumni once.
  static Future<QuerySnapshot> getAlumni() {
    return db
        .collection('alumni')
        .where('isVerified', isEqualTo: true)
        .get();
  }

  // ─── Q&A ────────────────────────────────────────────────────────────────

  /// Real-time stream of Q&A questions, latest first.
  static Stream<QuerySnapshot> getQAStream() {
    return db
        .collection('qa')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Post a new question from a student.
  static Future<DocumentReference> postQuestion(Map<String, dynamic> data) {
    return db.collection('qa').add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
      'upvotes': 0,
      'isAnswered': false,
    });
  }

  /// Post an alumni answer to a question.
  static Future<void> postAnswer(
      String questionId, Map<String, dynamic> answer) async {
    await Future.wait([
      db
          .collection('qa')
          .doc(questionId)
          .collection('answers')
          .add({...answer, 'answeredAt': FieldValue.serverTimestamp()}),
      db
          .collection('qa')
          .doc(questionId)
          .update({'isAnswered': true}),
    ]);
  }

  /// Upvote a question.
  static Future<void> upvoteQuestion(String questionId) {
    return db
        .collection('qa')
        .doc(questionId)
        .update({'upvotes': FieldValue.increment(1)});
  }

  // ─── Placement Analytics ────────────────────────────────────────────────

  static Future<QuerySnapshot> getPlacementData() {
    return db.collection('placement_analytics').get();
  }

  // ─── Mentorship ─────────────────────────────────────────────────────────

  /// Send a mentorship request from student to alumni.
  static Future<void> requestMentorship({
    required String studentId,
    required String alumniId,
    required String alumniName,
    required String alumniCompany,
  }) {
    return db.collection('mentorship_requests').add({
      'studentId': studentId,
      'alumniId': alumniId,
      'alumniName': alumniName,
      'alumniCompany': alumniCompany,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream of a specific student-alumni mentorship request status.
  static Stream<QuerySnapshot> getMentorshipStatus({
    required String studentId,
    required String alumniId,
  }) {
    return db
        .collection('mentorship_requests')
        .where('studentId', isEqualTo: studentId)
        .where('alumniId', isEqualTo: alumniId)
        .snapshots();
  }

  /// Stream of all mentorship requests for a student.
  static Stream<QuerySnapshot> getStudentMentorships(String studentId) {
    return db
        .collection('mentorship_requests')
        .where('studentId', isEqualTo: studentId)
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  // ─── Notifications ───────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getNotifications(String userId) {
    return db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> markNotificationRead(String notificationId) {
    return db
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // ─── Roadmap (Firestore mirror) ──────────────────────────────────────────

  /// Mirror roadmap progress to Firestore for cross-device sync.
  static Future<void> updateRoadmapProgress({
    required String userId,
    required String roadmapName,
    required int milestonesCompleted,
  }) {
    return db.collection('students').doc(userId).update({
      'activeRoadmap': roadmapName,
      'roadmapProgress.$roadmapName': milestonesCompleted,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // ─── Messaging ───────────────────────────────────────────────────────────

  /// Send a message in a conversation.
  static Future<void> sendMessage({
    required String conversationId,
    required Map<String, dynamic> message,
  }) async {
    await Future.wait([
      db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({...message, 'sentAt': FieldValue.serverTimestamp()}),
      db.collection('conversations').doc(conversationId).set(
        {
          'lastMessage': message['text'],
          'lastMessageAt': FieldValue.serverTimestamp(),
          'participants': message['participants'],
        },
        SetOptions(merge: true),
      ),
    ]);
  }

  /// Stream of messages in a conversation.
  static Stream<QuerySnapshot> getMessages(String conversationId) {
    return db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();
  }
}
