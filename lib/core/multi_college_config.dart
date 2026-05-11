/// Multi-College Configuration — GraduWay Phase 3
///
/// Architecture for expanding beyond Aditya Engineering College.
/// Each college gets isolated: Firestore collection prefix,
/// separate alumni directory, independent placement analytics.
///
/// Phase 1 (current): Single college — Aditya Engineering College
/// Phase 3 (roadmap): Multi-college SaaS with per-college data isolation
class CollegeConfig {
  final String collegeId;
  final String collegeName;
  final String emailDomain;
  final String firestorePrefix;
  final String logoUrl;
  final List<String> branches;

  const CollegeConfig({
    required this.collegeId,
    required this.collegeName,
    required this.emailDomain,
    required this.firestorePrefix,
    required this.logoUrl,
    required this.branches,
  });

  /// Firestore collection path — isolated per college
  String collection(String name) => '$firestorePrefix/$name';
}

/// Current active college configuration
const CollegeConfig activeCollege = CollegeConfig(
  collegeId: 'aditya_ec',
  collegeName: 'Aditya Engineering College',
  emailDomain: 'aec.edu.in',
  firestorePrefix: 'colleges/aditya_ec',
  logoUrl: 'assets/logos/aditya_logo.png',
  branches: ['CSE', 'ECE', 'MECH', 'EEE', 'IT', 'CIVIL'],
);

/// Phase 3: Additional college configurations ready to activate
const List<CollegeConfig> supportedColleges = [
  activeCollege,
  // Uncomment to enable multi-college in Phase 3:
  // CollegeConfig(
  //   collegeId: 'jntu_k',
  //   collegeName: 'JNTU Kakinada',
  //   emailDomain: 'jntuk.edu.in',
  //   firestorePrefix: 'colleges/jntu_k',
  //   logoUrl: 'assets/logos/jntu_logo.png',
  //   branches: ['CSE', 'ECE', 'MECH', 'EEE', 'IT'],
  // ),
];
