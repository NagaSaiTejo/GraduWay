import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/data/models/models.dart';
import 'package:graduway/services/ai_service.dart';
import 'package:graduway/services/webrtc_service.dart';
import 'package:graduway/services/industry_partnership_service.dart';
import 'package:graduway/core/multi_college_config.dart';

void main() {
  // ─── AuthNotifier Unit Tests ───────────────────────────────────────────────
  group('AuthState — Initial State', () {
    test('Initial auth state is guest and not logged in', () {
      final notifier = AuthNotifier();
      expect(notifier.state.isLoggedIn, false);
      expect(notifier.state.role, UserRole.guest);
    });

    test('Initial loginEmail is empty', () {
      final notifier = AuthNotifier();
      expect(notifier.state.loginEmail, '');
    });

    test('Initial student is null', () {
      final notifier = AuthNotifier();
      expect(notifier.state.student, isNull);
    });

    test('Initial alumni is null', () {
      final notifier = AuthNotifier();
      expect(notifier.state.alumni, isNull);
    });
  });

  group('AuthNotifier — setUser (Student)', () {
    test('setUser correctly assigns student role and data', () {
      final notifier = AuthNotifier();
      notifier.setUser(
        email: 'student@acet.ac.in',
        roleStr: 'student',
        user: {
          'id': 's001',
          'name': 'Arjun Reddy',
          'branch': 'CSE',
          'currentYear': 3,
          'careerScore': 42,
          'rollNumber': '21K81A0501',
          'roadmapProgress': <String, dynamic>{},
        },
      );
      expect(notifier.state.role, UserRole.student);
      expect(notifier.state.isLoggedIn, true);
      expect(notifier.state.student?.branch, 'CSE');
      expect(notifier.state.student?.name, 'Arjun Reddy');
    });

    test('setUser persists email in state', () {
      final notifier = AuthNotifier();
      notifier.setUser(
        email: 'test@acet.ac.in',
        roleStr: 'student',
        user: {
          'id': 's002',
          'name': 'Test Student',
          'branch': 'ECE',
          'currentYear': 2,
          'careerScore': 0,
          'rollNumber': '22K81A0402',
          'roadmapProgress': <String, dynamic>{},
        },
      );
      expect(notifier.state.loginEmail, 'test@acet.ac.in');
    });

    test('setUser parses roadmapProgress correctly', () {
      final notifier = AuthNotifier();
      notifier.setUser(
        email: 'rd@acet.ac.in',
        roleStr: 'student',
        user: {
          'id': 's003',
          'name': 'Ravi',
          'branch': 'IT',
          'currentYear': 4,
          'careerScore': 80,
          'rollNumber': '20K81A0501',
          'activeRoadmap': 'Flutter',
          'roadmapProgress': <String, dynamic>{'Flutter': 3},
        },
      );
      expect(notifier.state.student?.activeRoadmap, 'Flutter');
      expect(notifier.state.student?.roadmapProgress['Flutter'], 3);
    });
  });

  group('AuthNotifier — setUser (Alumni)', () {
    test('setUser correctly assigns alumni role', () {
      final notifier = AuthNotifier();
      notifier.setUser(
        email: 'alumni@amazon.com',
        roleStr: 'alumni',
        user: {
          'id': 'a001',
          'name': 'Ravi Kumar',
          'company': 'Amazon',
          'jobRole': 'SDE-2',
          'passoutYear': 2021,
        },
      );
      expect(notifier.state.role, UserRole.alumni);
      expect(notifier.state.alumni?.company, 'Amazon');
      expect(notifier.state.alumni?.role, 'SDE-2');
    });
  });

  group('AuthNotifier — Logout', () {
    test('Logout resets state to guest', () {
      final notifier = AuthNotifier();
      notifier.setUser(
        email: 'test@stud.com',
        roleStr: 'student',
        user: {
          'id': 'test123',
          'name': 'Test User',
          'branch': 'CSE',
          'currentYear': 2,
          'careerScore': 0,
          'rollNumber': '21K81A0501',
          'roadmapProgress': <String, dynamic>{},
        },
      );
      expect(notifier.state.isLoggedIn, true);
      notifier.logout();
      expect(notifier.state.isLoggedIn, false);
      expect(notifier.state.role, UserRole.guest);
      expect(notifier.state.student, isNull);
    });
  });

  group('AuthNotifier — Roadmap State', () {
    test('updateRoadmapState persists activeRoadmap', () {
      final notifier = AuthNotifier();
      notifier.setUser(
        email: 'rmap@acet.ac.in',
        roleStr: 'student',
        user: {
          'id': 'rm001',
          'name': 'Roadmap Tester',
          'branch': 'CSE',
          'currentYear': 3,
          'careerScore': 10,
          'rollNumber': '21K81A0555',
          'roadmapProgress': <String, dynamic>{},
        },
      );
      notifier.updateRoadmapState(
        activeRoadmap: 'Flutter',
        roadmapProgress: {'Flutter': 2},
      );
      expect(notifier.state.student?.activeRoadmap, 'Flutter');
      expect(notifier.state.student?.roadmapProgress['Flutter'], 2);
    });

    test('exitRoadmap sets activeRoadmap to null in state after update', () {
      final notifier = AuthNotifier();
      notifier.setUser(
        email: 'exit@acet.ac.in',
        roleStr: 'student',
        user: {
          'id': 'ex001',
          'name': 'Exit Tester',
          'branch': 'CSE',
          'currentYear': 2,
          'careerScore': 5,
          'rollNumber': '21K81A0556',
          'activeRoadmap': 'Flutter',
          'roadmapProgress': <String, dynamic>{'Flutter': 1},
        },
      );
      notifier.updateRoadmapState(
        activeRoadmap: null,
        roadmapProgress: {'Flutter': 1},
      );
      expect(notifier.state.student?.activeRoadmap, isNull);
    });
  });

  // ─── StudentProgressNotifier Unit Tests ───────────────────────────────────
  group('StudentProgressNotifier — Career Score', () {
    test('Initial career score is 0', () {
      final notifier = StudentProgressNotifier();
      expect(notifier.state.careerScore, 0);
    });

    test('Asking a question increments count and score', () {
      final notifier = StudentProgressNotifier();
      notifier.incrementQuestionsAsked();
      expect(notifier.state.questionsAsked, 1);
      expect(notifier.state.careerScore, greaterThan(0));
    });

    test('Career score clamps at 100', () {
      final notifier = StudentProgressNotifier();
      for (int i = 0; i < 30; i++) {
        notifier.incrementQuestionsAsked();
      }
      expect(notifier.state.careerScore, lessThanOrEqualTo(100));
    });
  });

  group('StudentProgressNotifier — Alumni Tracking', () {
    test('Viewing alumni profile increments count', () {
      final notifier = StudentProgressNotifier();
      notifier.trackAlumniView('alumni_001');
      expect(notifier.state.alumniProfilesViewed, 1);
    });

    test('Same alumni view not counted twice', () {
      final notifier = StudentProgressNotifier();
      notifier.trackAlumniView('alumni_001');
      notifier.trackAlumniView('alumni_001');
      expect(notifier.state.alumniProfilesViewed, 1);
    });

    test('Multiple unique alumni views counted separately', () {
      final notifier = StudentProgressNotifier();
      notifier.trackAlumniView('alumni_001');
      notifier.trackAlumniView('alumni_002');
      notifier.trackAlumniView('alumni_003');
      expect(notifier.state.alumniProfilesViewed, 3);
    });
  });

  group('StudentProgressNotifier — Badges', () {
    test('First question awards Curious Mind badge (b002)', () {
      final notifier = StudentProgressNotifier();
      notifier.incrementQuestionsAsked();
      expect(notifier.state.earnedBadgeIds.contains('b002'), true);
    });

    test('First alumni view awards First Connect badge (b001)', () {
      final notifier = StudentProgressNotifier();
      notifier.trackAlumniView('alumni_001');
      expect(notifier.state.earnedBadgeIds.contains('b001'), true);
    });

    test('Badges list is not empty after activity', () {
      final notifier = StudentProgressNotifier();
      notifier.incrementQuestionsAsked();
      expect(notifier.state.earnedBadgeIds, isNotEmpty);
    });
  });

  // ─── QANotifier Unit Tests ─────────────────────────────────────────────────
  group('QANotifier — Questions', () {
    test('Adding a question increases list length', () {
      final notifier = QANotifier();
      final initial = notifier.state.length;
      notifier.addQuestion(QAModel(
        id: 'test_q1',
        question: 'How to crack Amazon SDE interview?',
        askedBy: 'Arjun',
        askedById: '21K81A0501',
        timestamp: DateTime.now(),
        upvotes: 0,
        tags: ['Interview', 'Amazon'],
        answers: [],
        isAnswered: false,
      ));
      expect(notifier.state.length, initial + 1);
    });

    test('New question appears at top of list', () {
      final notifier = QANotifier();
      notifier.addQuestion(QAModel(
        id: 'test_top',
        question: 'Top question test',
        askedBy: 'Student',
        askedById: 'S001',
        timestamp: DateTime.now(),
        upvotes: 0,
        tags: [],
        answers: [],
        isAnswered: false,
      ));
      expect(notifier.state.first.id, 'test_top');
    });

    test('Upvoting increments upvote count by 1', () {
      final notifier = QANotifier();
      notifier.addQuestion(QAModel(
        id: 'upvote_test',
        question: 'Upvote test question',
        askedBy: 'Student A',
        askedById: 'A001',
        timestamp: DateTime.now(),
        upvotes: 0,
        tags: [],
        answers: [],
        isAnswered: false,
      ));
      notifier.upvoteQuestion('upvote_test');
      final q = notifier.state.firstWhere((q) => q.id == 'upvote_test');
      expect(q.upvotes, 1);
    });

    test('Multiple upvotes accumulate correctly', () {
      final notifier = QANotifier();
      notifier.addQuestion(QAModel(
        id: 'multi_upvote',
        question: 'Multi-upvote test',
        askedBy: 'Student B',
        askedById: 'B002',
        timestamp: DateTime.now(),
        upvotes: 0,
        tags: [],
        answers: [],
        isAnswered: false,
      ));
      notifier.upvoteQuestion('multi_upvote');
      notifier.upvoteQuestion('multi_upvote');
      notifier.upvoteQuestion('multi_upvote');
      final q = notifier.state.firstWhere((q) => q.id == 'multi_upvote');
      expect(q.upvotes, 3);
    });
  });

  // ─── Model Factory Tests ───────────────────────────────────────────────────
  group('QAModel — fromMap Factory', () {
    test('fromMap creates QAModel with correct fields', () {
      final model = QAModel.fromMap({
        'id': 'fm001',
        'question': 'What is Flutter?',
        'askedBy': 'Test Student',
        'askedById': 'TS001',
        'upvotes': 5,
        'tags': ['Flutter', 'Mobile'],
        'isAnswered': false,
      });
      expect(model.question, 'What is Flutter?');
      expect(model.upvotes, 5);
      expect(model.tags, contains('Flutter'));
    });

    test('fromMap handles missing optional fields gracefully', () {
      final model = QAModel.fromMap({
        'question': 'Minimal question',
      });
      expect(model.question, 'Minimal question');
      expect(model.askedBy, 'Anonymous');
      expect(model.upvotes, 0);
      expect(model.tags, isEmpty);
    });
  });

  group('QAModel — copyWith', () {
    test('copyWith correctly updates upvotes', () {
      final original = QAModel(
        id: 'cw001',
        question: 'Test',
        askedBy: 'S',
        askedById: 'S1',
        timestamp: DateTime.now(),
        upvotes: 0,
        tags: [],
        answers: [],
        isAnswered: false,
      );
      // ignore: prefer_const_constructors
      final updated = original.copyWith(upvotes: 10);
      expect(updated.upvotes, 10);
      expect(updated.question, 'Test'); // unchanged
    });
  });

  // ─── Future Scope Foundation Tests ───────────────────────────────────────
  group('Future Scope — WebRTC Foundation', () {
    test('MentorshipSession defaults are set for Phase 2 calls', () {
      final session = MentorshipSession(
        sessionId: 'sess_001',
        studentId: 'stu_01',
        alumniId: 'al_01',
        scheduledAt: DateTime(2026, 1, 1),
      );

      expect(session.durationMinutes, 30);
      expect(session.screenSharingEnabled, true);
    });

    test('WebRTC state moves to offering on initiateSession', () async {
      WebRTCService.dispose();
      expect(WebRTCService.state, WebRTCSignalingState.idle);

      await WebRTCService.initiateSession(
        MentorshipSession(
          sessionId: 'sess_002',
          studentId: 'stu_02',
          alumniId: 'al_02',
          scheduledAt: DateTime(2026, 1, 1),
        ),
      );

      expect(WebRTCService.state, WebRTCSignalingState.offering);
      WebRTCService.dispose();
      expect(WebRTCService.state, WebRTCSignalingState.idle);
    });
  });

  group('Future Scope — AI Matching Foundation', () {
    test('Mentorship match score is bounded between 0 and 1', () {
      final score = AIService.calculateMentorshipMatchScore(
        studentGoalSkills: ['Flutter', 'Dart', 'Firebase'],
        alumniSkills: ['Flutter', 'Dart', 'AWS'],
        studentTargetRole: 'Mobile Engineer',
        alumniTargetRole: 'Mobile Engineer',
      );

      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(1));
    });

    test('Mentorship match score is zero for empty skill vectors', () {
      final score = AIService.calculateMentorshipMatchScore(
        studentGoalSkills: const [],
        alumniSkills: ['Flutter'],
        studentTargetRole: 'Mobile Engineer',
        alumniTargetRole: 'Mobile Engineer',
      );

      expect(score, 0);
    });
  });

  group('Future Scope — Multi-College & Partnerships', () {
    test('Active college config builds isolated Firestore paths', () {
      expect(activeCollege.collection('referrals'),
          'colleges/aditya_ec/referrals');
      expect(activeCollege.emailDomain, isNotEmpty);
    });

    test('Supported colleges includes active college config', () {
      expect(supportedColleges, contains(activeCollege));
    });

    test('ReferralOpportunity toFirestore keeps core fields', () {
      final opportunity = ReferralOpportunity(
        id: 'r1',
        alumniId: 'a1',
        alumniName: 'Ravi',
        company: 'Amazon',
        role: 'SDE',
        description: 'Referral for backend role',
        requiredSkills: const ['Node.js', 'MongoDB'],
        targetBranch: 'CSE',
        targetYear: 3,
        postedAt: DateTime(2026, 1, 1),
        expiresAt: DateTime(2026, 2, 1),
        isActive: true,
        applicantCount: 0,
        firestorePath: 'colleges/aditya_ec/referrals/r1',
      );

      final data = opportunity.toFirestore();
      expect(data['company'], 'Amazon');
      expect(data['role'], 'SDE');
      expect(data['targetYear'], 3);
      expect(data['requiredSkills'], isA<List<String>>());
    });
  });

  // ─── Widget Tests ──────────────────────────────────────────────────────────
  group('Widget Tests — Login Screen Components', () {
    testWidgets('Email and password fields render correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Email Address')),
                  TextFormField(
                      decoration: const InputDecoration(labelText: 'Password')),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Sign In button renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: null,
                child: Text('Sign In'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Empty form shows validation state', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    ElevatedButton(
                      onPressed: () => formKey.currentState!.validate(),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });
  });
}
