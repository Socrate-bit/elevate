import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:elevate/features/chat/cubit/chat_list_cubit.dart';
import 'package:elevate/features/chat/cubit/chat_list_state.dart';
import 'package:elevate/features/chat/services/chat_conversation.dart';
import 'package:elevate/features/chat/services/chat_firestore_service.dart';
import 'package:elevate/features/chat/services/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

class _MockRepo extends Mock implements ChatRepository {}

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

ChatConversation _conv(String id, {String title = '', int lastAt = 0}) =>
    ChatConversation(
      id: id,
      title: title,
      createdAt: DateTime.fromMillisecondsSinceEpoch(lastAt),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(lastAt),
    );

void main() {
  late _MockRepo repo;
  late StreamController<List<ChatConversation>> stream;

  setUpAll(() {
    registerFallbackValue(_conv('fallback'));
  });

  setUp(() {
    repo = _MockRepo();
    stream = StreamController<List<ChatConversation>>.broadcast();
    when(repo.watchConversations).thenAnswer((_) => stream.stream);
    when(() => repo.saveConversation(any())).thenAnswer((_) async {});
    when(() => repo.deleteConversation(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await stream.close();
  });

  group('ChatListCubit', () {
    test('initial state is empty', () {
      final cubit = ChatListCubit(repository: repo);
      expect(cubit.state, const ChatListState());
    });

    blocTest<ChatListCubit, ChatListState>(
      'start() emits loading then fills conversations from stream',
      build: () => ChatListCubit(repository: repo),
      act: (cubit) async {
        cubit.start();
        await Future<void>.delayed(Duration.zero);
        stream.add([_conv('a', lastAt: 100), _conv('b', lastAt: 200)]);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const ChatListState(isLoading: true),
        ChatListState(
          conversations: [_conv('a', lastAt: 100), _conv('b', lastAt: 200)],
        ),
      ],
    );

    blocTest<ChatListCubit, ChatListState>(
      'setSearchQuery updates state and filters conversations',
      build: () => ChatListCubit(repository: repo),
      seed: () => ChatListState(
        conversations: [
          _conv('1', title: 'Hello world'),
          _conv('2', title: 'Greetings friend'),
        ],
      ),
      act: (cubit) => cubit.setSearchQuery('hello'),
      verify: (cubit) {
        expect(cubit.state.searchQuery, 'hello');
        expect(cubit.state.filtered.map((c) => c.id), ['1']);
      },
    );

    test('filtered returns all conversations when query empty', () {
      final cubit = ChatListCubit(repository: repo);
      final all = [_conv('1', title: 'a'), _conv('2', title: 'b')];
      cubit.emit(ChatListState(conversations: all));
      expect(cubit.state.filtered, all);
    });

    test('createConversation inserts optimistically and persists', () async {
      final cubit = ChatListCubit(
        repository: repo,
        uuid: _FixedUuid(['new-id']),
      );
      final conv = await cubit.createConversation();
      expect(conv.id, 'new-id');
      expect(cubit.state.conversations.first.id, 'new-id');
      verify(() => repo.saveConversation(any())).called(1);
    });

    test('createConversation rolls back on persistence failure', () async {
      when(() => repo.saveConversation(any()))
          .thenThrow(Exception('boom'));
      final cubit = ChatListCubit(
        repository: repo,
        uuid: _FixedUuid(['rollback-id']),
      );
      await expectLater(cubit.createConversation(), throwsException);
      expect(cubit.state.conversations, isEmpty);
    });

    test('deleteConversation removes optimistically and persists', () async {
      final cubit = ChatListCubit(repository: repo);
      cubit.emit(ChatListState(
        conversations: [_conv('a'), _conv('b')],
      ));
      await cubit.deleteConversation('a');
      expect(cubit.state.conversations.map((c) => c.id), ['b']);
      verify(() => repo.deleteConversation('a')).called(1);
    });

    test('deleteConversation restores list on failure', () async {
      when(() => repo.deleteConversation(any()))
          .thenThrow(Exception('boom'));
      final cubit = ChatListCubit(repository: repo);
      final originals = [_conv('a'), _conv('b')];
      cubit.emit(ChatListState(conversations: originals));
      await cubit.deleteConversation('a');
      expect(cubit.state.conversations, originals);
    });

    test('clear cancels stream and resets state', () async {
      final cubit = ChatListCubit(repository: repo);
      cubit.start();
      await Future<void>.delayed(Duration.zero);
      stream.add([_conv('a')]);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.conversations, isNotEmpty);

      cubit.clear();
      expect(cubit.state, const ChatListState());
    });
  });

  // Sanity import so ChatMessage stays in deps even if unused above.
  test('imports compile', () {
    expect(ChatRole.user, isNotNull);
  });
}
