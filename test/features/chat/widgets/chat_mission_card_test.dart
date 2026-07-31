import 'package:elevate/features/chat/services/chat_mission_suggestion.dart';
import 'package:elevate/features/chat/widgets/chat_mission_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_harness.dart';

void main() {
  testWidgets('pending suggestion renders activity + start/decline',
      (tester) async {
    const s = ChatMissionSuggestion(
      toolKey: 'meditation',
      reason: 'You seem stressed — a short meditation could help.',
    );
    var started = false;
    var declined = false;
    await tester.pumpWidget(harness(ChatMissionCard(
      suggestion: s,
      onAccept: () => started = true,
      onDecline: () => declined = true,
    )));

    // Resolves the tool by key → shows its title + the AI reason + actions.
    expect(find.text('Meditation'), findsOneWidget);
    expect(
      find.text('You seem stressed — a short meditation could help.'),
      findsOneWidget,
    );
    expect(find.text('Start Mission'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);

    await tester.tap(find.text('Start Mission'));
    await tester.pump();
    expect(started, isTrue);
    expect(declined, isFalse);
  });

  testWidgets('unknown tool key still renders a usable card', (tester) async {
    const s = ChatMissionSuggestion(toolKey: 'bogus', reason: 'Try this.');
    await tester.pumpWidget(harness(ChatMissionCard(
      suggestion: s,
      onAccept: () {},
      onDecline: () {},
    )));
    // Never blank: the reason + an action button are always present.
    expect(find.text('Try this.'), findsOneWidget);
    expect(find.text('Start Mission'), findsWidgets);
  });

  testWidgets('accepted suggestion shows a status row, no buttons',
      (tester) async {
    const s = ChatMissionSuggestion(
      toolKey: 'meditation',
      reason: 'r',
      accepted: true,
    );
    await tester.pumpWidget(harness(ChatMissionCard(
      suggestion: s,
      onAccept: () {},
      onDecline: () {},
    )));
    expect(find.text('Start Mission'), findsNothing);
    expect(find.text('Not now'), findsNothing);
    expect(find.text('Mission started'), findsOneWidget);
  });
}
