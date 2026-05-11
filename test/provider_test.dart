import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/providers/firestore_providers.dart';
import 'package:graduway/data/models/alumni_model.dart';

void main() {
  test('StudentProgressNotifier increments questions and awards badge', () {
    // Create a container to hold the providers
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state check
    var state = container.read(studentProgressProvider);
    expect(state.questionsAsked, 0);
    expect(
        state.earnedBadgeIds.contains('b002'), isFalse); // Curious Mind badge

    // Action: Increment question
    container.read(studentProgressProvider.notifier).incrementQuestionsAsked();

    // Verify state updated
    state = container.read(studentProgressProvider);
    expect(state.questionsAsked, 1);

    // Verify badge awarded on first question
    expect(state.earnedBadgeIds.contains('b002'), isTrue);
  });

  test(
      'searchedAlumniProvider uses Firestore-backed alumni data when available',
      () async {
    const liveAlumni = AlumniModel(
      id: 'a100',
      name: 'Live Alumni',
      batch: '2020',
      branch: 'CSE',
      company: 'Amazon',
      role: 'SDE',
      location: 'Hyderabad',
      package: 20,
      skills: ['Flutter', 'Dart'],
      photoUrl: '',
      advice: '',
      story: '',
      linkedIn: '',
      isVerified: true,
      menteeCount: 1,
      rating: 4.9,
      anonConfession: '',
      interviewRounds: [],
      targetRole: 'FAANG',
      email: 'live@alum.com',
      yearsOfExp: 3,
    );

    final container = ProviderContainer(
      overrides: [
        alumniStreamProvider.overrideWith((ref) => Stream.value([liveAlumni])),
      ],
    );
    addTearDown(container.dispose);

    await container.read(alumniStreamProvider.future);

    container.read(alumniSearchProvider.notifier).state = 'amazon';
    final results = container.read(searchedAlumniProvider);

    expect(results, hasLength(1));
    expect(results.first.id, 'a100');
    expect(results.first.company, 'Amazon');
  });
}
