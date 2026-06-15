import 'package:elevate/sk_features/chat/services/chat_form.dart';
import 'package:elevate/sk_features/chat/services/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage', () {
    final created = DateTime.fromMillisecondsSinceEpoch(1700000000000);

    test('equality via Equatable', () {
      final a = ChatMessage(
        id: '1',
        conversationId: 'c1',
        role: ChatRole.user,
        text: 'hi',
        createdAt: created,
      );
      final b = ChatMessage(
        id: '1',
        conversationId: 'c1',
        role: ChatRole.user,
        text: 'hi',
        createdAt: created,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith preserves untouched fields', () {
      final m = ChatMessage(
        id: '1',
        conversationId: 'c1',
        role: ChatRole.user,
        text: 'hi',
        createdAt: created,
      );
      final copy = m.copyWith(text: 'hello');
      expect(copy.text, 'hello');
      expect(copy.id, '1');
      expect(copy.conversationId, 'c1');
      expect(copy.role, ChatRole.user);
      expect(copy.createdAt, created);
    });

    test('toMap / fromMap round-trip for plain text', () {
      final m = ChatMessage(
        id: 'm1',
        conversationId: 'c1',
        role: ChatRole.model,
        text: 'hello there',
        createdAt: created,
      );
      final map = m.toMap();
      final restored = ChatMessage.fromMap('m1', 'c1', map);
      expect(restored, equals(m));
    });

    test('toMap / fromMap round-trip with form', () {
      final m = ChatMessage(
        id: 'm2',
        conversationId: 'c1',
        role: ChatRole.model,
        text: '',
        createdAt: created,
        form: const ChatForm(
          question: 'Pick one',
          options: ['A', 'B'],
          selectedIndex: 1,
        ),
      );
      final restored = ChatMessage.fromMap('m2', 'c1', m.toMap());
      expect(restored, equals(m));
      expect(restored.form?.selectedIndex, 1);
    });

    test('fromMap defaults role to user on unknown string', () {
      final restored = ChatMessage.fromMap('x', 'c', {
        'role': 'something_unknown',
        'text': 'hi',
        'createdAtMs': 100,
      });
      expect(restored.role, ChatRole.user);
    });
  });
}
