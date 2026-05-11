import 'dart:async';

import 'package:elevate/features/chat/cubit/chat_cubit.dart';
import 'package:elevate/features/chat/cubit/chat_list_cubit.dart';
import 'package:elevate/features/chat/cubit/chat_list_state.dart';
import 'package:elevate/features/chat/screens/chat_history_screen.dart';
import 'package:elevate/features/chat/screens/chat_screen.dart';
import 'package:elevate/features/chat/services/chat_conversation.dart';
import 'package:elevate/features/chat/services/chat_firestore_service.dart';
import 'package:elevate/features/chat/services/chat_form.dart';
import 'package:elevate/features/chat/services/chat_message.dart';
import 'package:elevate/features/chat/services/gemini_service.dart';
import 'package:elevate/features/chat/services/voice_service.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

class _MockRepo extends Mock implements ChatRepository {}

class _MockGemini extends Mock implements GeminiClient {}

class _NoopVoice implements VoiceController {
  @override
  bool get isAvailable => true;
  @override
  bool get isListening => false;
  @override
  Future<bool> initialize() async => true;
  @override
  Future<void> start({required void Function(String) onPartial}) async {}
  @override
  Future<void> stop() async {}
}

class _SeqUuid extends Fake implements Uuid {
  _SeqUuid(this._values);
  final List<String> _values;
  int _i = 0;
  @override
  String v4({Map<String, dynamic>? options, V4Options? config}) {
    final v = _values[_i % _values.length];
    _i++;
    return v;
  }
}

ChatConversation _conv(String id, {String title = ''}) {
  final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
  return ChatConversation(
    id: id,
    title: title,
    createdAt: now,
    lastMessageAt: now,
  );
}

ChatMessage _msg(
  String id, {
  required ChatRole role,
  String text = '',
  ChatForm? form,
}) =>
    ChatMessage(
      id: id,
      conversationId: 'c1',
      role: role,
      text: text,
      form: form,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    );

/// Pumps a screen with the full app scaffolding (theme + l10n + ScreenUtil).
Widget appHarness(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(414, 896),
    minTextAdapt: true,
    splitScreenMode: true,
    // ignore: unnecessary_underscores
    builder: (_, __) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  late _MockRepo repo;
  late _MockGemini gemini;
  late StreamController<List<ChatMessage>> messages;
  late StreamController<List<ChatConversation>> conversations;

  setUpAll(() {
    registerFallbackValue(_conv('fallback'));
    registerFallbackValue(_msg('fallback', role: ChatRole.user));
  });

  setUp(() {
    repo = _MockRepo();
    gemini = _MockGemini();
    messages = StreamController<List<ChatMessage>>.broadcast();
    conversations = StreamController<List<ChatConversation>>.broadcast();

    when(repo.watchConversations).thenAnswer((_) => conversations.stream);
    when(() => repo.watchMessages(any())).thenAnswer((_) => messages.stream);

    when(() => repo.saveMessage(any())).thenAnswer((_) async {});
    when(() => repo.saveConversation(any())).thenAnswer((_) async {});
    when(() => repo.deleteConversation(any())).thenAnswer((_) async {});
    when(() => repo.updateConversation(
          any(),
          title: any(named: 'title'),
          lastMessageAt: any(named: 'lastMessageAt'),
        )).thenAnswer((_) async {});
    when(() => repo.updateMessageForm(any(), any(), any()))
        .thenAnswer((_) async {});

    when(() => gemini.generateTitle(any())).thenAnswer((_) async => 'Title');
  });

  tearDown(() async {
    await messages.close();
    await conversations.close();
  });

  testWidgets(
    'E2E: send text → bubbles render → form arrives via stream → '
    'tap option records selection',
    (tester) async {
      final replies = <GeminiReply>[
        GeminiReply.text('Hi there!'),
        GeminiReply.text('Nice choice.'),
      ];
      var sendCount = 0;
      when(() => gemini.send(
            history: any(named: 'history'),
            userText: any(named: 'userText'),
          )).thenAnswer((_) async => replies[sendCount++]);

      final cubit = ChatCubit(
        conversationId: 'c1',
        repository: repo,
        gemini: gemini,
        voice: _NoopVoice(),
        uuid: _SeqUuid(['u1', 'm1', 'u2', 'm2']),
      );

      await tester.pumpWidget(appHarness(
        BlocProvider<ChatCubit>.value(
          value: cubit,
          child: ChatScreen(conversation: _conv('c1')),
        ),
      ));
      // Flip isLoading false by pushing an initial empty snapshot.
      messages.add([]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Empty state shows greeting.
      expect(find.text('How can I help you tonight?'), findsOneWidget);

      // Type and send.
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // User bubble appears optimistically.
      expect(find.text('hello'), findsOneWidget);

      // Simulate Firestore pushing the persisted user + model messages back
      // via the watchMessages stream (what would happen in production).
      messages.add([
        _msg('u1', role: ChatRole.user, text: 'hello'),
        _msg('m1', role: ChatRole.model, text: 'Hi there!'),
      ]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hi there!'), findsOneWidget);

      // Simulate the next model turn delivering a form card (as if Gemini
      // had returned `present_choices`).
      messages.add([
        _msg('u1', role: ChatRole.user, text: 'hello'),
        _msg('m1', role: ChatRole.model, text: 'Hi there!'),
        _msg(
          'form1',
          role: ChatRole.model,
          form: const ChatForm(
            question: 'Pick a color',
            options: ['Red', 'Blue'],
          ),
        ),
      ]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pick a color'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);

      // Tap the option — should record the selection.
      await tester.tap(find.text('Red'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      verify(() => repo.updateMessageForm('c1', 'form1', 0)).called(1);
      // Plus a user-side save for the chosen label.
      verify(() => gemini.send(
            history: any(named: 'history'),
            userText: 'Red',
          )).called(1);

      await cubit.close();
    },
  );

  testWidgets(
    'E2E history: list renders, search filters conversations, '
    'createConversation persists',
    (tester) async {
      final list = ChatListCubit(
        repository: repo,
        uuid: _SeqUuid(['brand-new']),
      );
      list.emit(ChatListState(conversations: [
        _conv('a', title: 'Apples'),
        _conv('b', title: 'Bananas'),
      ]));

      await tester.pumpWidget(appHarness(
        BlocProvider<ChatListCubit>.value(
          value: list,
          child: const ChatHistoryScreen(),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsOneWidget);

      // Search filters by title.
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pump();
      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsNothing);

      // Clear search restores the full list.
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('Bananas'), findsOneWidget);

      // Add-FAB renders; invoke createConversation directly to verify the
      // cubit's persistence path without triggering navigation to a screen
      // that would build a real Firestore-backed ChatCubit.
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      await list.createConversation();
      verify(() => repo.saveConversation(any())).called(1);
      expect(list.state.conversations.first.id, 'brand-new');

      await list.close();
    },
  );
}
