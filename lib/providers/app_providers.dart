import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/alumni_model.dart';
import '../data/models/models.dart';
import '../data/models/student_model.dart';
import '../data/mock/alumni_data.dart';
import '../data/mock/placement_data.dart';
import '../core/api_config.dart';
import 'firestore_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────────────────────────────────────

enum UserRole { guest, student, alumni, admin }

class AuthState {
  final UserRole role;
  final bool isLoggedIn;
  final StudentModel? student;
  final AlumniModel? alumni;
  final String loginEmail;
  final String loginName;
  final String bio;
  final String? profileImageUrl;
  final String? loginError;
  final bool isLoggingIn;

  const AuthState({
    this.role = UserRole.guest,
    this.isLoggedIn = false,
    this.student,
    this.alumni,
    this.loginEmail = '',
    this.loginName = '',
    this.bio = '',
    this.profileImageUrl,
    this.loginError,
    this.isLoggingIn = false,
  });

  AuthState copyWith({
    UserRole? role,
    bool? isLoggedIn,
    StudentModel? student,
    AlumniModel? alumni,
    String? loginEmail,
    String? loginName,
    String? bio,
    String? profileImageUrl,
    String? loginError,
    bool? isLoggingIn,
  }) {
    return AuthState(
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      student: student ?? this.student,
      alumni: alumni ?? this.alumni,
      loginEmail: loginEmail ?? this.loginEmail,
      loginName: loginName ?? this.loginName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      loginError: loginError,
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // Called ONLY on successful login — no state change during loading,
  // so GoRouter never rebuilds/resets to /splash while awaiting the HTTP call.
  void setUser({
    required String email,
    required String roleStr,
    required Map<String, dynamic> user,
  }) {
    final name = user['name'] as String? ?? email.split('@').first;
    final profileImageUrl = user['profileImageUrl'] as String?;

    UserRole role;
    StudentModel? studentModel;
    AlumniModel? alumniModel;

    if (roleStr == 'student') {
      role = UserRole.student;
      final progressMap =
          user['roadmapProgress'] as Map<String, dynamic>? ?? {};
      final parsedProgress =
          progressMap.map((k, v) => MapEntry(k, (v as num).toInt()));

      studentModel = StudentModel(
        id: user['id'] as String,
        name: name,
        email: email,
        branch: user['branch'] as String? ?? '',
        year: (user['currentYear'] as num?)?.toInt() ?? 0,
        targetCareer: '',
        skills: const [],
        careerScore: (user['careerScore'] as num?)?.toInt() ?? 0,
        earnedBadges: const [],
        questionsAsked: 0,
        mentorSessionsAttended: 0,
        photoUrl: profileImageUrl ?? '',
        rollNumber: user['rollNumber'] as String? ?? '',
        activeRoadmap: user['activeRoadmap'] as String?,
        roadmapProgress: parsedProgress,
      );
    } else if (roleStr == 'alumni') {
      role = UserRole.alumni;
      alumniModel = AlumniModel(
        id: user['id'] as String,
        name: name,
        email: email,
        company: user['company'] as String? ?? '',
        role: user['jobRole'] as String? ?? '',
        batch: (user['passoutYear'] as num?)?.toString() ?? '',
        branch: '',
        skills: const [],
        linkedIn: '',
        photoUrl: profileImageUrl ?? '',
        advice: '',
        story: '',
        isVerified: false,
        menteeCount: 0,
        rating: 0.0,
        anonConfession: '',
        interviewRounds: const [],
        targetRole: '',
        location: '',
        package: 0.0,
        yearsOfExp: 0,
      );
    } else {
      role = UserRole.admin;
    }

    state = AuthState(
      role: role,
      isLoggedIn: true,
      loginEmail: email,
      loginName: name,
      student: studentModel,
      alumni: alumniModel,
      profileImageUrl: profileImageUrl,
    );
  }

  /// Save name and bio edits from the Edit Profile sheet (works for all roles).
  void updateUserProfile({required String name, required String bio}) {
    state = state.copyWith(loginName: name, bio: bio);
  }

  /// Update the student's roadmap state after an API call
  void updateRoadmapState(
      {required String? activeRoadmap,
      required Map<String, int> roadmapProgress,
      int? careerScore}) {
    if (state.student != null) {
      final updatedStudent = StudentModel(
        id: state.student!.id,
        name: state.student!.name,
        email: state.student!.email,
        branch: state.student!.branch,
        year: state.student!.year,
        targetCareer: state.student!.targetCareer,
        skills: state.student!.skills,
        careerScore: careerScore ?? state.student!.careerScore,
        earnedBadges: state.student!.earnedBadges,
        questionsAsked: state.student!.questionsAsked,
        mentorSessionsAttended: state.student!.mentorSessionsAttended,
        photoUrl: state.student!.photoUrl,
        rollNumber: state.student!.rollNumber,
        activeRoadmap: activeRoadmap,
        roadmapProgress: roadmapProgress,
      );
      state = state.copyWith(student: updatedStudent);
    }
  }

  Future<void> selectRoadmap(String roadmapName) async {
    try {
      final email = state.student?.email ?? state.loginEmail;
      if (email.isEmpty) {
        debugPrint('Cannot select roadmap: No email found in state.');
        return;
      }
      final response = await http.post(
        Uri.parse(ApiConfig.roadmapSelect),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'roadmapName': roadmapName}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final progressMap = data['roadmapProgress'] as Map<String, dynamic>;
        updateRoadmapState(
          activeRoadmap: data['activeRoadmap'],
          roadmapProgress:
              progressMap.map((k, v) => MapEntry(k, (v as num).toInt())),
        );
      } else {
        debugPrint('Failed to select roadmap: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error selecting roadmap: $e');
    }
  }

  Future<void> exitRoadmap() async {
    try {
      final email = state.student?.email ?? state.loginEmail;
      if (email.isEmpty) return;
      final response = await http.post(
        Uri.parse(ApiConfig.roadmapExit),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final progressMap = data['roadmapProgress'] as Map<String, dynamic>;
        updateRoadmapState(
          activeRoadmap: null,
          roadmapProgress:
              progressMap.map((k, v) => MapEntry(k, (v as num).toInt())),
        );
      } else {
        debugPrint('Failed to exit roadmap: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error exiting roadmap: $e');
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Student Live State — real progress tracking
// ─────────────────────────────────────────────────────────────────────────────

class StudentProgressState {
  final int questionsAsked;
  final int eventsAttended;
  final int mentorSessions;
  final int alumniProfilesViewed;
  final List<String> viewedAlumniIds;
  final List<String> earnedBadgeIds;
  final List<BadgeNotification> pendingNotifications;
  final String? localPhotoPath; // profile photo from device
  final String displayName;
  final String bio;
  final String targetCareer;

  const StudentProgressState({
    this.questionsAsked = 0,
    this.eventsAttended = 0,
    this.mentorSessions = 0,
    this.alumniProfilesViewed = 0,
    this.viewedAlumniIds = const [],
    this.earnedBadgeIds = const [],
    this.pendingNotifications = const [],
    this.localPhotoPath,
    this.displayName = 'Arjun Reddy',
    this.bio = '',
    this.targetCareer = '',
  });

  int get careerScore {
    final base = (questionsAsked * 5) +
        (eventsAttended * 10) +
        (mentorSessions * 15) +
        (earnedBadgeIds.length * 8);
    return base.clamp(0, 100);
  }

  StudentProgressState copyWith({
    int? questionsAsked,
    int? eventsAttended,
    int? mentorSessions,
    int? alumniProfilesViewed,
    List<String>? viewedAlumniIds,
    List<String>? earnedBadgeIds,
    List<BadgeNotification>? pendingNotifications,
    String? localPhotoPath,
    String? displayName,
    String? bio,
    String? targetCareer,
    bool clearPhoto = false,
  }) {
    return StudentProgressState(
      questionsAsked: questionsAsked ?? this.questionsAsked,
      eventsAttended: eventsAttended ?? this.eventsAttended,
      mentorSessions: mentorSessions ?? this.mentorSessions,
      alumniProfilesViewed: alumniProfilesViewed ?? this.alumniProfilesViewed,
      viewedAlumniIds: viewedAlumniIds ?? this.viewedAlumniIds,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
      localPhotoPath:
          clearPhoto ? null : (localPhotoPath ?? this.localPhotoPath),
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      targetCareer: targetCareer ?? this.targetCareer,
    );
  }
}

class BadgeNotification {
  final String badgeId;
  final String title;
  final String emoji;
  const BadgeNotification(this.badgeId, this.title, this.emoji);
}

class StudentProgressNotifier extends StateNotifier<StudentProgressState> {
  StudentProgressNotifier() : super(const StudentProgressState());

  /// Call after student posts a question
  void incrementQuestionsAsked() {
    final newCount = state.questionsAsked + 1;
    var newState = state.copyWith(questionsAsked: newCount);
    // Award badge: first question
    if (newCount == 1) {
      newState = _awardBadge(newState, 'b002', 'Curious Mind', '❓');
    }
    // Award badge: 5 questions
    if (newCount == 5) {
      newState = _awardBadge(newState, 'b008', 'Community Hero', '💬');
    }
    state = newState;
  }

  /// Call when student RSVPs to an event
  void attendEvent() {
    final newCount = state.eventsAttended + 1;
    var newState = state.copyWith(eventsAttended: newCount);
    if (newCount == 1) {
      newState = _awardBadge(newState, 'b004', 'Event Goer', '🎓');
    }
    state = newState;
  }

  /// Call when student views an alumni profile
  void trackAlumniView(String alumniId) {
    if (state.viewedAlumniIds.contains(alumniId)) return; // already counted
    final newIds = [...state.viewedAlumniIds, alumniId];
    var newState = state.copyWith(
      alumniProfilesViewed: newIds.length,
      viewedAlumniIds: newIds,
    );
    if (newIds.length == 1) {
      newState = _awardBadge(newState, 'b001', 'First Connect', '🤝');
    }
    if (newIds.length == 5) {
      newState = _awardBadge(newState, 'b007', 'Network Builder', '🌐');
    }
    state = newState;
  }

  /// Call when student picks a career goal on roadmap
  void setTargetCareer(String career) {
    var newState = state.copyWith(targetCareer: career);
    if (!state.earnedBadgeIds.contains('b003')) {
      newState = _awardBadge(newState, 'b003', 'Skill Seeker', '🎯');
    }
    state = newState;
  }

  /// Call after profile score crosses 50
  void checkPlacementReady() {
    if (state.careerScore >= 50 && !state.earnedBadgeIds.contains('b010')) {
      state = _awardBadge(state, 'b010', 'Placement Ready', '🚀');
    }
  }

  void updateProfile(String name, String bio) {
    state = state.copyWith(displayName: name, bio: bio);
    if (name.isNotEmpty &&
        bio.isNotEmpty &&
        !state.earnedBadgeIds.contains('b009')) {
      state = _awardBadge(state, 'b009', 'Goal Setter', '🏁');
    }
  }

  void updateProfilePhoto(String? path) {
    if (path == null) {
      state = state.copyWith(clearPhoto: true);
    } else {
      state = state.copyWith(localPhotoPath: path);
    }
  }

  void clearNotification(String badgeId) {
    state = state.copyWith(
      pendingNotifications: state.pendingNotifications
          .where((n) => n.badgeId != badgeId)
          .toList(),
    );
  }

  StudentProgressState _awardBadge(
      StudentProgressState s, String id, String title, String emoji) {
    if (s.earnedBadgeIds.contains(id)) return s;
    return s.copyWith(
      earnedBadgeIds: [...s.earnedBadgeIds, id],
      pendingNotifications: [
        ...s.pendingNotifications,
        BadgeNotification(id, title, emoji)
      ],
    );
  }
}

final studentProgressProvider =
    StateNotifierProvider<StudentProgressNotifier, StudentProgressState>(
  (ref) => StudentProgressNotifier(),
);

// Convenience derived
final careerScoreProvider =
    Provider<int>((ref) => ref.watch(studentProgressProvider).careerScore);

// ─────────────────────────────────────────────────────────────────────────────
// Shared Q&A State
// ─────────────────────────────────────────────────────────────────────────────

class QANotifier extends StateNotifier<List<QAModel>> {
  QANotifier() : super(mockQA);

  void replaceAll(List<QAModel> questions) {
    state = questions;
  }

  void addQuestion(QAModel question) {
    state = [question, ...state];
  }

  void upvoteQuestion(String questionId) {
    state = state
        .map((q) => q.id == questionId ? q.copyWith(upvotes: q.upvotes + 1) : q)
        .toList();
  }

  void addAnswer(String questionId, QAAnswer answer) {
    state = state.map((q) {
      if (q.id == questionId) {
        return q.copyWith(
          answers: [...q.answers, answer],
          isAnswered: true,
        );
      }
      return q;
    }).toList();
  }
}

final qaProvider = StateNotifierProvider<QANotifier, List<QAModel>>(
  (ref) => QANotifier(),
);

final unansweredQAProvider = Provider<List<QAModel>>((ref) {
  return ref.watch(qaProvider).where((q) => !q.isAnswered).toList();
});

final trendingQAProvider = Provider<List<QAModel>>((ref) {
  final all = ref.watch(qaProvider);
  final sorted = [...all]..sort((a, b) => b.upvotes.compareTo(a.upvotes));
  return sorted.take(5).toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Alumni Filtering & Search
// ─────────────────────────────────────────────────────────────────────────────

final alumniSearchProvider = StateProvider<String>((ref) => '');
final selectedBranchProvider = StateProvider<String>((ref) => 'All');

final alumniListProvider = Provider<List<AlumniModel>>((ref) {
  final firestoreAlumni = ref.watch(alumniStreamProvider);
  return firestoreAlumni.when(
    data: (list) => list,
    loading: () => const [],
    error: (_, __) => const [],
  );
});

final searchedAlumniProvider = Provider<List<AlumniModel>>((ref) {
  final query = ref.watch(alumniSearchProvider).toLowerCase();
  final branch = ref.watch(selectedBranchProvider);
  final alumni = ref.watch(alumniListProvider);
  return alumni.where((a) {
    final matchesBranch = branch == 'All' || a.branch == branch;
    final matchesQuery = query.isEmpty ||
        a.name.toLowerCase().contains(query) ||
        a.company.toLowerCase().contains(query) ||
        a.skills.any((s) => s.toLowerCase().contains(query));
    return matchesBranch && matchesQuery;
  }).toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Career Goal State (Roadmap)
// ─────────────────────────────────────────────────────────────────────────────

final careerGoalProvider = StateProvider<String>((ref) => '');

// ─────────────────────────────────────────────────────────────────────────────
// Navigation tab index per role
// ─────────────────────────────────────────────────────────────────────────────

final studentNavIndexProvider = StateProvider<int>((ref) => 0);
final alumniNavIndexProvider = StateProvider<int>((ref) => 0);
final adminNavIndexProvider = StateProvider<int>((ref) => 0);

// Global flag to ensure onboarding is only seen once per app session/install
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);
