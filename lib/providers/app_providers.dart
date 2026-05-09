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
        // Check MongoDB for user profile and role
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

        // If user exists in Auth but not in DB (shouldn't happen with proper registration)
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

  void logout() async {
    await _authService.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider), ref.read(databaseServiceProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Real-time Data Providers (replacing mock)
// ─────────────────────────────────────────────────────────────────────────────

final alumniListProvider = FutureProvider<List<AlumniModel>>((ref) async {
  return ref.read(databaseServiceProvider).getAllAlumni(onlyVerified: true);
});

final qaListProvider = FutureProvider<List<QAModel>>((ref) async {
  return ref.read(databaseServiceProvider).getAllQA();
});

final suggestedAlumniProvider = Provider<List<AlumniModel>>((ref) {
  final student = ref.watch(authProvider).student;
  final allAlumni = ref.watch(alumniListProvider).value ?? [];

  if (student == null) return [];

  return AISuggestionService.getSuggestions(student, allAlumni);
});

// ─────────────────────────────────────────────────────────────────────────────
// Legacy/Mock providers (to be gradually replaced or updated to wrap new logic)
// ─────────────────────────────────────────────────────────────────────────────

final studentProgressProvider = StateProvider<int>((ref) => 0); // Simplified for now

final alumniSearchProvider = StateProvider<String>((ref) => '');
final selectedBranchProvider = StateProvider<String>((ref) => 'All');

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
