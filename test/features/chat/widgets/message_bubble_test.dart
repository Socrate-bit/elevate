import 'package:elevate/features/chat/services/chat_message.dart';
import 'package:elevate/features/chat/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_harness.dart';

void main() {
  ChatMessage make(ChatRole role) => ChatMessage(
        id: '1',
        conversationId: 'c1',
        role: role,
        text: 'Hello world',
        createdAt: DateTime.now(),
      );

  testWidgets('renders text content', (tester) async {
    await tester.pumpWidget(harness(MessageBubble(message: make(ChatRole.user))));
    expect(find.text('Hello world'), findsOneWidget);
  });

  testWidgets('user bubble aligns right', (tester) async {
    await tester.pumpWidget(harness(MessageBubble(message: make(ChatRole.user))));
    final align = tester.widget<Align>(find.byType(Align));
    expect(align.alignment, Alignment.centerRight);
  });

  testWidgets('model bubble aligns left', (tester) async {
    await tester
        .pumpWidget(harness(MessageBubble(message: make(ChatRole.model))));
    final align = tester.widget<Align>(find.byType(Align));
    expect(align.alignment, Alignment.centerLeft);
  });
}
