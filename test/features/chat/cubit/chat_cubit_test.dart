import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:elevate/features/chat/cubit/chat_cubit.dart';
import 'package:elevate/features/chat/cubit/chat_state.dart';
import 'package:elevate/features/chat/services/chat_firestore_service.dart';
import 'package:elevate/features/chat/services/chat_form.dart';
import 'package:elevate/features/chat/services/chat_message.dart';
import 'package:elevate/features/chat/services/gemini_service.dart';
import 'package:elevate/features/chat/services/voice_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

class _MockRepo extends Mock implements ChatRepository {}

class _MockGemini extends Mock implements GeminiClient {}

class _FakeVoice implements VoiceController {
  bool _initOk = true;
  bool _listening = false;
  void Function(String)? _onPartial;
  bool throwOnStart = false;
  bool initShouldFail = false;

  @override
  bool get isAvailable => _initOk;

  @override
  bool get isListening => _listening;

  @override
  Future<bool> initialize() async {
    if (initShouldFail) _initOk = false;
    return _initOk;
  }

  @override
  Future<void> start({
    required void Function(String transcript) onPartial,
  }) async {
    if (throwOnStart) throw const VoiceUnavailableException();
    _listening = true;
    _onPartial = onPartial;
  }

  @override
  Future<void> stop() async {
    _listening = false;
  }

  /// Test helper: feed a fake partial transcript.
  void feed(String text) => _onPartial?.call(text);
}

class _FixedUuid extends Fake implements Uuid {
  _FixedUuid(this._values);
  final List<String> _values;
  int _i = 0;

  @override
  String v4({Map<String, dynamic>? options, V4Options? config}) {
    final v = _values[_i % _values.length];
    _i++;
    return v;
  }
}

ChatMessage _msg(
  String id, {
  String text = '',
  ChatRole role = ChatRole.user,
  ChatForm? form,
  double? insightProgress,
  int createdAtMs = 0,
}) =>
    ChatMessage(
      id: id,
      conversationId: 'c1',
      role: role,
      text: text,
      form: form,
      insightProgress: insightProgress,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );

void main() {
  late _MockRepo repo;
  late _MockGemini gemini;
  late _FakeVoice voice;
  late StreamController<List<ChatMessage>> messages;

  setUpAll(() {
    registerFallbackValue(_msg('fallback'));
  });

  setUp(() {
    repo = _MockRepo();
    gemini = _MockGemini();
    voice = _FakeVoice();
    messages = StreamController<List<ChatMessage>>.broadcast();

    when(() => repo.watchMessages(any())).thenAnswer((_) => messages.stream);
    when(() => repo.saveMessage(any())).thenAnswer((_) async {});
    when(() => repo.updateConversation(
          any(),
          title: any(named: 'title'),
          lastMessageAt: any(named: 'lastMessageAt'),
          summary: any(named: 'summary'),
          summaryAt: any(named: 'summaryAt'),
          memoryExtracted: any(named: 'memoryExtracted'),
        )).thenAnswer((_) async {});
    when(() => repo.updateMessageForm(any(), any(), any()))
        .thenAnswer((_) async {});
    when(() => repo.updateMessageInsightProgress(any(), any(), any()))
        .thenAnswer((_) async {});
    when(() => gemini.assessInsightProgress(history: any(named: 'history')))
        .thenAnswer((_) async => 0.4);
    when(() => gemini.generateTitle(any()))
        .thenAnswer((_) async => 'A title');
    when(() => gemini.send(
          history: any(named: 'history'),
          userText: any(named: 'userText'),
          memoryContext: any(named: 'memoryContext'),
        )).thenAnswer((_) async => GeminiReply.text('hello back'));
  });

  tearDown(() async {
    await messages.close();
  });

  ChatCubit buildCubit({List<String> ids = const ['u1', 'm1']}) {
    return ChatCubit(
      conversationId: 'c1',
      repository: repo,
      gemini: gemini,
      voice: voice,
      uuid: _FixedUuid(ids),
    );
  }

  group('ChatCubit subscribe', () {
    blocTest<ChatCubit, ChatState>(
      'emits loading then messages when stream fires',
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        messages.add([_msg('seed', text: 'hi', role: ChatRole.user)]);
        await Future<void>.delayed(Duration.zero);
      },
      verify: (cubit) {
        expect(cubit.state.isLoading, false);
        expect(cubit.state.messages.single.id, 'seed');
      },
    );
  });

  group('sendText', () {
    test('optimistically inserts user message, persists both turns, '
        'calls Gemini', () async {
      final cubit = buildCubit(ids: ['user-id', 'model-id']);
      await cubit.sendText('hello');

      // Local state shows the optimistic user bubble; the model bubble lives
      // in Firestore and would arrive via the watchMessages stream in prod.
      expect(cubit.state.messages.single.role, ChatRole.user);
      expect(cubit.state.messages.single.text, 'hello');
      expect(cubit.state.isSending, false);

      final saved = verify(() => repo.saveMessage(captureAny())).captured;
      expect(saved.length, 2);
      expect((saved[0] as ChatMessage).role, ChatRole.user);
      expect((saved[0] as ChatMessage).text, 'hello');
      expect((saved[1] as ChatMessage).role, ChatRole.model);
      expect((saved[1] as ChatMessage).text, 'hello back');

      verify(() => gemini.send(
            history: any(named: 'history'),
            userText: 'hello',
          )).called(1);
    });

    test('ignores empty or whitespace text', () async {
      final cubit = buildCubit();
      await cubit.sendText('   ');
      expect(cubit.state.messages, isEmpty);
      verifyNever(() => repo.saveMessage(any()));
    });

    test('rolls back optimistic insert when persistence fails', () async {
      when(() => repo.saveMessage(any())).thenThrow(Exception('boom'));
      final cubit = buildCubit();
      await expectLater(cubit.sendText('hello'), throwsException);
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.isSending, false);
    });

    test('first user message triggers title generation', () async {
      final cubit = buildCubit();
      await cubit.sendText('first');
      // generateTitle runs unawaited; give it a tick.
      await Future<void>.delayed(Duration.zero);
      verify(() => gemini.generateTitle('first')).called(1);
      verify(() => repo.updateConversation('c1', title: 'A title')).called(1);
    });

    test('second user message does not trigger title generation', () async {
      final cubit = buildCubit(ids: ['u1', 'm1', 'u2', 'm2']);
      await cubit.sendText('first');
      await Future<void>.delayed(Duration.zero);
      clearInteractions(gemini);
      when(() => gemini.send(
            history: any(named: 'history'),
            userText: any(named: 'userText'),
            memoryContext: any(named: 'memoryContext'),
          )).thenAnswer((_) async => GeminiReply.text('hello back 2'));

      await cubit.sendText('second');
      verifyNever(() => gemini.generateTitle(any()));
    });

    test('persists a form when Gemini returns a structured reply', () async {
      when(() => gemini.send(
            history: any(named: 'history'),
            userText: any(named: 'userText'),
          )).thenAnswer((_) async => GeminiReply.form(
            const ChatForm(question: 'Pick', options: ['A', 'B']),
          ));
      final cubit = buildCubit();
      await cubit.sendText('hello');

      final saved = verify(() => repo.saveMessage(captureAny())).captured;
      final modelMsg = saved[1] as ChatMessage;
      expect(modelMsg.role, ChatRole.model);
      expect(modelMsg.form, isNotNull);
      expect(modelMsg.form!.options, ['A', 'B']);
    });
  });

  group('insight progress', () {
    test('stores the assessed progress on the model reply message', () async {
      final cubit = buildCubit(ids: ['user-id', 'model-id']);
      await cubit.sendText('hello');
      // _assessAndStoreProgress runs unawaited; give it a tick.
      await Future<void>.delayed(Duration.zero);

      verify(() => gemini.assessInsightProgress(history: any(named: 'history')))
          .called(1);
      verify(() =>
              repo.updateMessageInsightProgress('c1', 'model-id', 0.4))
          .called(1);
    });

    test('ring reads stored progress from the latest message, no recompute',
        () async {
      final cubit = buildCubit();
      await Future<void>.delayed(Duration.zero);
      messages.add([
        _msg('u', text: 'hi', role: ChatRole.user),
        _msg('m', text: 'hey', role: ChatRole.model, insightProgress: 0.7),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.insightProgress, 0.7);
      // Opening/loading an existing conversation never re-assesses.
      verifyNever(
        () => gemini.assessInsightProgress(history: any(named: 'history')),
      );
    });
  });

  group('answerForm', () {
    test('records selection and sends chosen option as next user turn',
        () async {
      final formMsg = _msg(
        'form-msg',
        role: ChatRole.model,
        form: const ChatForm(question: 'Pick', options: ['A', 'B']),
      );
      final cubit = buildCubit(ids: ['u2', 'm2']);
      cubit.emit(cubit.state.copyWith(messages: [formMsg]));

      await cubit.answerForm('form-msg', 1);

      // Form message updated optimistically.
      final updated =
          cubit.state.messages.firstWhere((m) => m.id == 'form-msg');
      expect(updated.form?.selectedIndex, 1);
      verify(() => repo.updateMessageForm('c1', 'form-msg', 1)).called(1);

      // Sent the chosen label.
      verify(() => gemini.send(
            history: any(named: 'history'),
            userText: 'B',
          )).called(1);
    });

    test('ignores invalid messageId, missing form, out-of-range index, '
        'and already-answered forms', () async {
      final answered = _msg(
        'answered',
        role: ChatRole.model,
        form: const ChatForm(
          question: 'Pick',
          options: ['A', 'B'],
          selectedIndex: 0,
        ),
      );
      final textOnly = _msg('text', role: ChatRole.model, text: 'hi');
      final cubit = buildCubit();
      cubit.emit(cubit.state.copyWith(messages: [answered, textOnly]));

      await cubit.answerForm('missing-id', 0);
      await cubit.answerForm('text', 0);
      await cubit.answerForm('answered', 1);
      await cubit.answerForm('answered', -1);

      verifyNever(() => repo.updateMessageForm(any(), any(), any()));
      verifyNever(() => gemini.send(
            history: any(named: 'history'),
            userText: any(named: 'userText'),
          ));
    });
  });

  group('voice', () {
    test('startListening flips flag and routes partials into state',
        () async {
      final cubit = buildCubit();
      await cubit.startListening();
      expect(cubit.state.isListening, true);

      voice.feed('hello');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.voicePartial, 'hello');
    });

    test('throws when voice unavailable on init', () async {
      voice.initShouldFail = true;
      final cubit = buildCubit();
      await expectLater(
        cubit.startListening(),
        throwsA(isA<VoiceUnavailableException>()),
      );
      expect(cubit.state.isListening, false);
    });

    test('stopListening returns transcript and resets flags', () async {
      final cubit = buildCubit();
      await cubit.startListening();
      voice.feed('the answer');
      await Future<void>.delayed(Duration.zero);

      final result = await cubit.stopListening();
      expect(result, 'the answer');
      expect(cubit.state.isListening, false);
      expect(cubit.state.voicePartial, '');
    });
  });
}
