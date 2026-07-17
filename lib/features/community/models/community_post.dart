import 'package:equatable/equatable.dart';

import 'community_profile.dart';

/// A single feed post. Stored at `community_posts/{postId}`; author identity is
/// denormalized so the feed renders without a profile join.
class CommunityPost extends Equatable {
  final String id;
  final String authorUid;
  final String authorUsername;
  final int authorAvatarId;
  final String tag;
  final String body;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  /// Uids that have liked this post (drives the current user's heart state).
  final List<String> likedBy;

  const CommunityPost({
    required this.id,
    required this.authorUid,
    required this.authorUsername,
    required this.authorAvatarId,
    required this.tag,
    required this.body,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.likedBy = const [],
  });

  String get authorAvatarAsset =>
      CommunityProfile.avatarAssetFor(authorAvatarId);

  bool likedByMe(String uid) => likedBy.contains(uid);

  CommunityPost copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    List<String>? likedBy,
  }) => CommunityPost(
    id: id,
    authorUid: authorUid,
    authorUsername: authorUsername,
    authorAvatarId: authorAvatarId,
    tag: tag,
    body: body,
    createdAt: createdAt,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    shareCount: shareCount ?? this.shareCount,
    likedBy: likedBy ?? this.likedBy,
  );

  Map<String, dynamic> toMap() => {
    'authorUid': authorUid,
    'authorUsername': authorUsername,
    'authorAvatarId': authorAvatarId,
    'tag': tag,
    'body': body,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'shareCount': shareCount,
    'likedBy': likedBy,
  };

  static CommunityPost fromMap(String id, Map<String, dynamic> m) =>
      CommunityPost(
        id: id,
        authorUid: m['authorUid'] as String? ?? '',
        authorUsername: m['authorUsername'] as String? ?? '',
        authorAvatarId: m['authorAvatarId'] as int? ?? 1,
        tag: m['tag'] as String? ?? '',
        body: m['body'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          m['createdAtMs'] as int? ?? 0,
        ),
        likeCount: m['likeCount'] as int? ?? 0,
        commentCount: m['commentCount'] as int? ?? 0,
        shareCount: m['shareCount'] as int? ?? 0,
        likedBy: (m['likedBy'] as List<dynamic>?)?.cast<String>() ?? const [],
      );

  @override
  List<Object?> get props => [
    id,
    authorUid,
    authorUsername,
    authorAvatarId,
    tag,
    body,
    createdAt,
    likeCount,
    commentCount,
    shareCount,
    likedBy,
  ];
}
