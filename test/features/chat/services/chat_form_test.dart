import 'package:elevate/features/chat/services/chat_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatForm', () {
    test('equality', () {
      const a = ChatForm(question: 'Q', options: ['A', 'B']);
      const b = ChatForm(question: 'Q', options: ['A', 'B']);
      expect(a, equals(b));
    });

    test('copyWith updates selectedIndex', () {
      const form = ChatForm(question: 'Pick', options: ['A', 'B', 'C']);
      final answered = form.copyWith(selectedIndex: 2);
      expect(answered.selectedIndex, 2);
      expect(answered.question, 'Pick');
      expect(answered.options, ['A', 'B', 'C']);
    });

    test('toMap / fromMap round-trip with selection', () {
      const form = ChatForm(
        question: 'Pick',
        options: ['A', 'B'],
        selectedIndex: 0,
      );
      final restored = ChatForm.fromMap(form.toMap());
      expect(restored, equals(form));
    });

    test('toMap omits selectedIndex when null', () {
      const form = ChatForm(question: 'Pick', options: ['A', 'B']);
      final map = form.toMap();
      expect(map.containsKey('selectedIndex'), isFalse);
    });

    test('fromMap reads default empty options if missing', () {
      final restored = ChatForm.fromMap({'question': 'q'});
      expect(restored.options, isEmpty);
    });
  });
}
