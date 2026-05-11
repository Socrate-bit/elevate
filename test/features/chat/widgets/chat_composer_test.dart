import 'package:elevate/features/chat/widgets/chat_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_harness.dart';

void main() {
  testWidgets('shows hint text', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(harness(ChatComposer(
      controller: controller,
      hint: 'Say something',
      isSending: false,
      isListening: false,
      onSend: () {},
      onMicTap: () {},
    )));
    expect(find.text('Say something'), findsOneWidget);
  });

  testWidgets('send disabled when text empty', (tester) async {
    var sent = false;
    final controller = TextEditingController();
    await tester.pumpWidget(harness(ChatComposer(
      controller: controller,
      hint: 'h',
      isSending: false,
      isListening: false,
      onSend: () => sent = true,
      onMicTap: () {},
    )));
    final sendIcon = find.byIcon(Icons.arrow_upward_rounded);
    await tester.tap(sendIcon);
    await tester.pump();
    expect(sent, isFalse);
  });

  testWidgets('send fires when text present', (tester) async {
    var sent = false;
    final controller = TextEditingController(text: 'hi');
    await tester.pumpWidget(harness(ChatComposer(
      controller: controller,
      hint: 'h',
      isSending: false,
      isListening: false,
      onSend: () => sent = true,
      onMicTap: () {},
    )));
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();
    expect(sent, isTrue);
  });

  testWidgets('mic icon swaps to stop while listening', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(harness(ChatComposer(
      controller: controller,
      hint: 'h',
      isSending: false,
      isListening: true,
      onSend: () {},
      onMicTap: () {},
    )));
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsNothing);
  });

  testWidgets('mic tap fires callback', (tester) async {
    var micTapped = false;
    final controller = TextEditingController();
    await tester.pumpWidget(harness(ChatComposer(
      controller: controller,
      hint: 'h',
      isSending: false,
      isListening: false,
      onSend: () {},
      onMicTap: () => micTapped = true,
    )));
    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    expect(micTapped, isTrue);
  });
}
