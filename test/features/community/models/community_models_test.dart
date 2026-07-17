import 'package:elevate/features/community/models/community_conversation.dart';
import 'package:elevate/features/community/models/community_group.dart';
import 'package:elevate/features/community/models/community_post.dart';
import 'package:elevate/features/community/models/community_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  group('CommunityProfile', () {
    test('avatarIdForUid is deterministic and within 1..4', () {
      for (final uid in ['a', 'user-123', 'ZZZ', '']) {
        final id = CommunityProfile.avatarIdForUid(uid);
        expect(id, inInclusiveRange(1, 4));
        expect(id, CommunityProfile.avatarIdForUid(uid)); // stable
      }
    });

    test('toMap includes lowercased username for search', () {
      final p = CommunityProfile(
        uid: 'u1',
        username: 'Calm_Cloud',
        avatarId: 3,
        createdAt: t0,
      );
      expect(p.toMap()['usernameLower'], 'calm_cloud');
    });

    test('toMap / fromMap round-trip', () {
      final p = CommunityProfile(
        uid: 'u1',
        username: 'mindful_mo',
        avatarId: 2,
        createdAt: t0,
      );
      expect(CommunityProfile.fromMap('u1', p.toMap()), equals(p));
    });
  });

  group('CommunityPost', () {
    CommunityPost post() => CommunityPost(
      id: 'p1',
      authorUid: 'u1',
      authorUsername: 'mo',
      authorAvatarId: 1,
      tag: 'Anxiety',
      body: 'hello',
      createdAt: t0,
      likeCount: 2,
      likedBy: const ['u2'],
    );

    test('likedByMe reflects likedBy membership', () {
      expect(post().likedByMe('u2'), isTrue);
      expect(post().likedByMe('u1'), isFalse);
    });

    test('toMap / fromMap round-trip', () {
      expect(CommunityPost.fromMap('p1', post().toMap()), equals(post()));
    });
  });

  group('CommunityGroup', () {
    test('joinedBy reflects membership', () {
      final g = CommunityGroup(
        id: 'g1',
        name: 'Anxiety Support',
        description: 'desc',
        avatarId: 1,
        memberCount: 5,
        memberUids: const ['u2'],
        createdAt: t0,
      );
      expect(g.joinedBy('u2'), isTrue);
      expect(g.joinedBy('u1'), isFalse);
      expect(CommunityGroup.fromMap('g1', g.toMap()), equals(g));
    });
  });

  group('CommunityConversation', () {
    test('idFor is commutative (same id regardless of order)', () {
      expect(
        CommunityConversation.idFor('a', 'b'),
        CommunityConversation.idFor('b', 'a'),
      );
    });

    test('otherUid / unreadFor helpers', () {
      final c = CommunityConversation(
        id: CommunityConversation.idFor('me', 'you'),
        participantUids: const ['me', 'you'],
        usernames: const {'me': 'Me', 'you': 'You'},
        avatarIds: const {'me': 1, 'you': 2},
        lastMessageAt: t0,
        unreadCounts: const {'me': 3, 'you': 0},
      );
      expect(c.otherUid('me'), 'you');
      expect(c.unreadFor('me'), 3);
      expect(c.usernameFor('you'), 'You');
      expect(CommunityConversation.fromMap(c.id, c.toMap()), equals(c));
    });
  });
}
