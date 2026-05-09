import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/alumni_model.dart';
import '../data/models/models.dart';
import '../data/models/student_model.dart';
import '../data/models/admin_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/ai_suggestion_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers for Services
// ─────────────────────────────────────────────────────────────────────────────

final authServiceProvider = Provider((ref) => AuthService());
final databaseServiceProvider = Provider((ref) => DatabaseService());

// ─────────────────────────────────────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────────────────────────────────────

enum UserRole { guest, student, alumni, admin }

class AuthState {
  final UserRole role;
  final bool isLoggedIn;
  final StudentModel? student;
  final AlumniModel? alumni;
  final AdminModel? admin;
  final String loginEmail;
  final String loginName;
  final String bio;
  final bool isVerified;

  const AuthState({
    this.role = UserRole.guest,
    this.isLoggedIn = false,
    this.student,
    this.alumni,
    this.admin,
    this.loginEmail = '',
    this.loginName = '',
    this.bio = '',
    this.isVerified = false,
  });

  AuthState copyWith({
    UserRole? role,
    bool? isLoggedIn,
    StudentModel? student,
    AlumniModel? alumni,
    AdminModel? admin,
    String? loginEmail,
    String? loginName,
    String? bio,
    bool? isVerified,
  }) {
    return AuthState(
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      student: student ?? this.student,
      alumni: alumni ?? this.alumni,
      admin: admin ?? this.admin,
      loginEmail: loginEmail ?? this.loginEmail,
      loginName: loginName ?? this.loginName,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

String _nameFromEmail(String email) {
  final local = email.split('@').first;
  final words = local.replaceAll(RegExp(r'[._\-]+'), ' ').split(' ');
  return words.map((w) {
    if (w.isEmpty) return '';
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ');
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final DatabaseService _dbService;

  AuthNotifier(this._authService, this._dbService) : super(const AuthState());

  Future<void> login(String email, String password) async {
    try {
      final userCredential = await _authService.signIn(email, password);
      if (userCredential?.user != null) {
        final student = await _dbService.getStudentByEmail(email);
        if (student != null) {
          state = AuthState(
            role: UserRole.student,
            isLoggedIn: true,
            loginEmail: email,
            loginName: student.name,
            student: student,
            isVerified: student.isVerified,
          );
          return;
        }

        final alumni = await _dbService.getAlumniByEmail(email);
        if (alumni != null) {
          state = AuthState(
            role: UserRole.alumni,
            isLoggedIn: true,
            loginEmail: email,
            loginName: alumni.name,
            alumni: alumni,
            isVerified: alumni.isVerified,
          );
          return;
        }

        final admin = await _dbService.getAdminByEmail(email);
        if (admin != null) {
          state = AuthState(
            role: UserRole.admin,
            isLoggedIn: true,
            loginEmail: email,
            loginName: admin.name,
            admin: admin,
            isVerified: true,
          );
          return;
        }

        throw Exception("User profile not found.");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerStudent(StudentModel student, String password) async {
    await _authService.signUp(student.email, password);
    await _dbService.saveStudent(student);
    state = AuthState(
      role: UserRole.student,
      isLoggedIn: true,
      loginEmail: student.email,
      loginName: student.name,
      student: student,
      isVerified: false,
    );
  }

  Future<void> registerAlumni(AlumniModel alumni, String password) async {
    await _authService.signUp(alumni.email, password);
    await _dbService.saveAlumni(alumni);
    state = AuthState(
      role: UserRole.alumni,
      isLoggedIn: true,
      loginEmail: alumni.email,
      loginName: alumni.name,
      alumni: alumni,
      isVerified: false,
    );
  }

  Future<void> registerAdmin(AdminModel admin, String password) async {
    await _authService.signUp(admin.email, password);
    await _dbService.saveAdmin(admin);
    state = AuthState(
      role: UserRole.admin,
      isLoggedIn: true,
      loginEmail: admin.email,
      loginName: admin.name,
      admin: admin,
      isVerified: true,
    );
  }

  void updateUserProfile({required String name, required String bio}) {
    state = state.copyWith(loginName: name, bio: bio);
  }

  void logout() async {
    await _authService.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider), ref.read(databaseServiceProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Student Live State
// ─────────────────────────────────────────────────────────────────────────────

class StudentProgressState {
  final int questionsAsked;
  final int eventsAttended;
  final int mentorSessions;
  final int alumniProfilesViewed;
  final List<String> viewedAlumniIds;
  final List<String> earnedBadgeIds;
  final List<BadgeNotification> pendingNotifications;
  final String? localPhotoPath;
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
    this.displayName = 'User',
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

  void incrementQuestionsAsked() {
    final newCount = state.questionsAsked + 1;
    var newState = state.copyWith(questionsAsked: newCount);
    if (newCount == 1) newState = _awardBadge(newState, 'b002', 'Curious Mind', '❓');
    if (newCount == 5) newState = _awardBadge(newState, 'b008', 'Community Hero', '💬');
    state = newState;
  }

  void attendEvent() {
    final newCount = state.eventsAttended + 1;
    var newState = state.copyWith(eventsAttended: newCount);
    if (newCount == 1) newState = _awardBadge(newState, 'b004', 'Event Goer', '🎓');
    state = newState;
  }

  void trackAlumniView(String alumniId) {
    if (state.viewedAlumniIds.contains(alumniId)) return;
    final newIds = [...state.viewedAlumniIds, alumniId];
    var newState = state.copyWith(
      alumniProfilesViewed: newIds.length,
      viewedAlumniIds: newIds,
    );
    if (newIds.length == 1) newState = _awardBadge(newState, 'b001', 'First Connect', '🤝');
    if (newIds.length == 5) newState = _awardBadge(newState, 'b007', 'Network Builder', '🌐');
    state = newState;
  }

  void setTargetCareer(String career) {
    var newState = state.copyWith(targetCareer: career);
    if (!state.earnedBadgeIds.contains('b003')) {
      newState = _awardBadge(newState, 'b003', 'Skill Seeker', '🎯');
    }
    state = newState;
  }

  void updateProfile(String name, String bio) {
    state = state.copyWith(displayName: name, bio: bio);
    if (name.isNotEmpty && bio.isNotEmpty && !state.earnedBadgeIds.contains('b009')) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Q&A State
// ─────────────────────────────────────────────────────────────────────────────

class QANotifier extends StateNotifier<List<QAModel>> {
  final DatabaseService _dbService;
  QANotifier(this._dbService) : super([]);

  Future<void> fetchQA() async {
    state = await _dbService.getAllQA();
  }

  void addQuestion(QAModel question) {
    state = [question, ...state];
  }

  void addAnswer(String questionId, QAAnswer answer) {
    state = state.map((q) {
      if (q.id == questionId) {
        return QAModel(
          id: q.id,
          question: q.question,
          askedBy: q.askedBy,
          askedById: q.askedById,
          timestamp: q.timestamp,
          upvotes: q.upvotes,
          tags: q.tags,
          answers: [...q.answers, answer],
          isAnswered: true,
        );
      }
      return q;
    }).toList();
  }
}

final qaProvider = StateNotifierProvider<QANotifier, List<QAModel>>(
  (ref) => QANotifier(ref.read(databaseServiceProvider)),
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
// Real-time Data Providers
// ─────────────────────────────────────────────────────────────────────────────

final alumniListProvider = FutureProvider<List<AlumniModel>>((ref) async {
  return ref.read(databaseServiceProvider).getAllAlumni(onlyVerified: true);
});

final qaListProvider = FutureProvider<List<QAModel>>((ref) async {
  final list = await ref.read(databaseServiceProvider).getAllQA();
  ref.read(qaProvider.notifier).state = list;
  return list;
});

final suggestedAlumniProvider = Provider<List<AlumniModel>>((ref) {
  final student = ref.watch(authProvider).student;
  final allAlumni = ref.watch(alumniListProvider).value ?? [];

  if (student == null) return [];

  return AISuggestionService.getSuggestions(student, allAlumni);
});

// ─────────────────────────────────────────────────────────────────────────────
// Filters & Other Providers
// ─────────────────────────────────────────────────────────────────────────────

final alumniSearchProvider = StateProvider<String>((ref) => '');
final selectedBranchProvider = StateProvider<String>((ref) => 'All');
final careerGoalProvider = StateProvider<String>((ref) => '');

final searchedAlumniProvider = Provider<List<AlumniModel>>((ref) {
  final query = ref.watch(alumniSearchProvider).toLowerCase();
  final branch = ref.watch(selectedBranchProvider);
  final allAlumni = ref.watch(alumniListProvider).value ?? [];

  return allAlumni.where((a) {
    final matchesBranch = branch == 'All' || a.branch == branch;
    final matchesQuery = query.isEmpty ||
        a.name.toLowerCase().contains(query) ||
        a.company.toLowerCase().contains(query) ||
        a.skills.any((s) => s.toLowerCase().contains(query));
    return matchesBranch && matchesQuery;
  }).toList();
});

final studentNavIndexProvider = StateProvider<int>((ref) => 0);
final alumniNavIndexProvider = StateProvider<int>((ref) => 0);
final adminNavIndexProvider = StateProvider<int>((ref) => 0);
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);
final careerScoreProvider = Provider<int>((ref) => ref.watch(studentProgressProvider).careerScore);
