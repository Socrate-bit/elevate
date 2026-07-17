import 'package:equatable/equatable.dart';

import 'community_profile.dart';

/// A comment on a post. Stored at `community_posts/{postId}/comments/{id}`.
class CommunityComment extends Equatable {
  final String id;
  final String authorUid;
  final String authorUsername;
  final int authorAvatarId;
  final String body;
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.authorUid,
    required this.authorUsername,
    required this.authorAvatarId,
    required this.body,
    required this.createdAt,
  });

  String get authorAvatarAsset =>
      CommunityProfile.avatarAssetFor(authorAvatarId);

  Map<String, dynamic> toMap() => {
    'authorUid': authorUid,
    'authorUsername': authorUsername,
    'authorAvatarId': authorAvatarId,
    'body': body,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
  };

  static CommunityComment fromMap(String id, Map<String, dynamic> m) =>
      CommunityComment(
        id: id,
        authorUid: m['authorUid'] as String? ?? '',
        authorUsername: m['authorUsername'] as String? ?? '',
        authorAvatarId: m['authorAvatarId'] as int? ?? 1,
        body: m['body'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          m['createdAtMs'] as int? ?? 0,
        ),
      );

  @override
  List<Object?> get props => [
    id,
    authorUid,
    authorUsername,
    authorAvatarId,
    body,
    createdAt,
  ];
}
