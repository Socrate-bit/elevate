import 'package:elevate/features/chat/services/chat_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatConversation', () {
    final created = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    final last = DateTime.fromMillisecondsSinceEpoch(1700001000000);

    test('equality', () {
      final a = ChatConversation(
        id: 'c1',
        title: 'Hello',
        createdAt: created,
        lastMessageAt: last,
      );
      final b = ChatConversation(
        id: 'c1',
        title: 'Hello',
        createdAt: created,
        lastMessageAt: last,
      );
      expect(a, equals(b));
    });

    test('copyWith', () {
      final c = ChatConversation(
        id: 'c1',
        title: 'Hello',
        createdAt: created,
        lastMessageAt: last,
      );
      final updated = c.copyWith(title: 'New');
      expect(updated.title, 'New');
      expect(updated.id, 'c1');
      expect(updated.createdAt, created);
      expect(updated.lastMessageAt, last);
    });

    test('toMap / fromMap round-trip', () {
      final c = ChatConversation(
        id: 'c1',
        title: 'My chat',
        createdAt: created,
        lastMessageAt: last,
      );
      final restored = ChatConversation.fromMap('c1', c.toMap());
      expect(restored, equals(c));
    });

    test('fromMap defaults missing fields', () {
      final c = ChatConversation.fromMap('c1', {});
      expect(c.id, 'c1');
      expect(c.title, '');
    });
  });
}
