import 'package:elevate/sk_features/chat/services/chat_form.dart';
import 'package:elevate/sk_features/chat/widgets/chat_form_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_harness.dart';

void main() {
  testWidgets('renders question and all options', (tester) async {
    const form = ChatForm(
      question: 'Pick a color',
      options: ['Red', 'Green', 'Blue'],
    );
    await tester.pumpWidget(harness(ChatFormCard(form: form, onAnswer: (_) {})));
    expect(find.text('Pick a color'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);
    expect(find.text('Green'), findsOneWidget);
    expect(find.text('Blue'), findsOneWidget);
  });

  testWidgets('tap fires onAnswer with index', (tester) async {
    int? picked;
    const form = ChatForm(question: 'Q', options: ['A', 'B', 'C']);
    await tester.pumpWidget(
      harness(ChatFormCard(form: form, onAnswer: (i) => picked = i)),
    );

    await tester.tap(find.text('B'));
    await tester.pump();
    expect(picked, 1);
  });

  testWidgets('answered form ignores taps', (tester) async {
    int? picked;
    const form = ChatForm(
      question: 'Q',
      options: ['A', 'B'],
      selectedIndex: 0,
    );
    await tester.pumpWidget(
      harness(ChatFormCard(form: form, onAnswer: (i) => picked = i)),
    );
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(picked, isNull);
  });
}
