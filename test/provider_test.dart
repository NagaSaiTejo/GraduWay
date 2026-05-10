import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/providers/app_providers.dart';

void main() {
  test('StudentProgressNotifier increments questions and awards badge', () {
    // Create a container to hold the providers
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state check
    var state = container.read(studentProgressProvider);
    expect(state.questionsAsked, 0);
    expect(state.earnedBadgeIds.contains('b002'), isFalse); // Curious Mind badge

    // Action: Increment question
    container.read(studentProgressProvider.notifier).incrementQuestionsAsked();

    // Verify state updated
    state = container.read(studentProgressProvider);
    expect(state.questionsAsked, 1);
    
    // Verify badge awarded on first question
    expect(state.earnedBadgeIds.contains('b002'), isTrue);
  });
}
