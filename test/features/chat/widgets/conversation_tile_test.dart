import 'package:elevate/sk_features/chat/services/chat_conversation.dart';
import 'package:elevate/sk_features/chat/widgets/conversation_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_harness.dart';

ChatConversation _conv({String title = ''}) {
  final now = DateTime.now();
  return ChatConversation(
    id: 'c1',
    title: title,
    createdAt: now,
    lastMessageAt: now,
  );
}

void main() {
  testWidgets('renders title when set', (tester) async {
    await tester.pumpWidget(harness(ConversationTile(
      conversation: _conv(title: 'My chat'),
      onTap: () {},
      onDelete: () {},
    )));
    expect(find.text('My chat'), findsOneWidget);
  });

  testWidgets('renders fallback when title empty', (tester) async {
    await tester.pumpWidget(harness(ConversationTile(
      conversation: _conv(),
      onTap: () {},
      onDelete: () {},
    )));
    // English fallback string.
    expect(find.text('New conversation'), findsOneWidget);
  });

  testWidgets('tap fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(harness(ConversationTile(
      conversation: _conv(title: 'X'),
      onTap: () => tapped = true,
      onDelete: () {},
    )));
    await tester.tap(find.text('X'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('long-press opens confirm dialog and Delete invokes onDelete',
      (tester) async {
    var deleted = false;
    await tester.pumpWidget(harness(ConversationTile(
      conversation: _conv(title: 'X'),
      onTap: () {},
      onDelete: () => deleted = true,
    )));
    await tester.longPress(find.text('X'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this conversation?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });
}
