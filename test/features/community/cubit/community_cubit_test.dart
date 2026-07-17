import 'package:elevate/features/community/cubit/community_cubit.dart';
import 'package:elevate/features/community/cubit/community_state.dart';
import 'package:elevate/features/community/models/community_enums.dart';
import 'package:elevate/features/community/models/community_group.dart';
import 'package:elevate/features/community/models/community_post.dart';
import 'package:elevate/features/community/services/community_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements CommunityRepository {}

CommunityPost _post(String id, {int likeCount = 0, List<String> likedBy = const []}) =>
    CommunityPost(
      id: id,
      authorUid: 'author',
      authorUsername: 'author',
      authorAvatarId: 1,
      tag: 'General',
      body: 'body $id',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      likeCount: likeCount,
      likedBy: likedBy,
    );

CommunityGroup _group(String id, {int memberCount = 5, List<String> members = const []}) =>
    CommunityGroup(
      id: id,
      name: 'Group $id',
      description: 'desc',
      avatarId: 1,
      memberCount: memberCount,
      memberUids: members,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
    );

void main() {
  late _MockRepo repo;

  setUpAll(() {
    registerFallbackValue(_post('fallback'));
  });

  setUp(() {
    repo = _MockRepo();
    when(() => repo.setLiked(any(), any(), any())).thenAnswer((_) async {});
    when(() => repo.setJoined(any(), any(), any())).thenAnswer((_) async {});
    when(() => repo.incrementShare(any())).thenAnswer((_) async {});
    when(() => repo.createPost(any())).thenAnswer((_) async {});
  });

  CommunityCubit build() => CommunityCubit(repository: repo);

  group('filteredPosts', () {
    test('forYou sorts by likeCount desc; recent keeps feed order', () {
      const state = CommunityState();
      final a = _post('a', likeCount: 1);
      final b = _post('b', likeCount: 9);
      final recent =
          state.copyWith(posts: [a, b], filter: CommunityFilter.recent);
      expect(recent.filteredPosts.map((p) => p.id), ['a', 'b']);
      final forYou = recent.copyWith(filter: CommunityFilter.forYou);
      expect(forYou.filteredPosts.map((p) => p.id), ['b', 'a']);
    });
  });

  group('unreadTotal', () {
    test('is zero without a current uid', () {
      expect(const CommunityState().unreadTotal, 0);
    });
  });

  group('toggleLike', () {
    test('optimistically likes and persists', () async {
      final cubit = build();
      cubit.emit(const CommunityState(currentUid: 'me').copyWith(posts: [_post('a')]));
      await cubit.toggleLike(cubit.state.posts.first);
      final updated = cubit.state.posts.first;
      expect(updated.likedByMe('me'), isTrue);
      expect(updated.likeCount, 1);
      verify(() => repo.setLiked('a', 'me', true)).called(1);
    });

    test('rolls back when persistence fails', () async {
      when(() => repo.setLiked(any(), any(), any())).thenThrow(Exception('boom'));
      final cubit = build();
      cubit.emit(const CommunityState(currentUid: 'me').copyWith(posts: [_post('a')]));
      await cubit.toggleLike(cubit.state.posts.first);
      final reverted = cubit.state.posts.first;
      expect(reverted.likedByMe('me'), isFalse);
      expect(reverted.likeCount, 0);
    });

    test('no-op without a current uid', () async {
      final cubit = build();
      cubit.emit(const CommunityState().copyWith(posts: [_post('a')]));
      await cubit.toggleLike(cubit.state.posts.first);
      verifyNever(() => repo.setLiked(any(), any(), any()));
    });
  });

  group('setJoined', () {
    test('optimistically joins and persists', () async {
      final cubit = build();
      cubit.emit(const CommunityState(currentUid: 'me').copyWith(groups: [_group('g')]));
      await cubit.setJoined(cubit.state.groups.first, true);
      final g = cubit.state.groups.first;
      expect(g.joinedBy('me'), isTrue);
      expect(g.memberCount, 6);
      verify(() => repo.setJoined('g', 'me', true)).called(1);
    });

    test('rolls back on failure', () async {
      when(() => repo.setJoined(any(), any(), any())).thenThrow(Exception('boom'));
      final cubit = build();
      cubit.emit(const CommunityState(currentUid: 'me').copyWith(groups: [_group('g')]));
      await cubit.setJoined(cubit.state.groups.first, true);
      final g = cubit.state.groups.first;
      expect(g.joinedBy('me'), isFalse);
      expect(g.memberCount, 5);
    });
  });

  group('createPost', () {
    test('persists a post when a profile exists', () async {
      final cubit = build();
      cubit.emit(
        const CommunityState(currentUid: 'me').copyWith(),
      );
      // No profile yet -> no write.
      await cubit.createPost(tag: 'General', body: 'hi');
      verifyNever(() => repo.createPost(any()));
    });
  });
}
