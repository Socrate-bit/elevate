import 'package:equatable/equatable.dart';

import 'community_profile.dart';

/// A support/community group. Stored at `community_groups/{groupId}`.
/// [memberUids] drives the current user's joined state; [memberCount] is the
/// displayed total (seeded high, incremented as real users join).
class CommunityGroup extends Equatable {
  final String id;
  final String name;
  final String description;
  final int avatarId;
  final int memberCount;
  final List<String> memberUids;
  final DateTime createdAt;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarId,
    this.memberCount = 0,
    this.memberUids = const [],
    required this.createdAt,
  });

  String get avatarAsset => CommunityProfile.avatarAssetFor(avatarId);

  bool joinedBy(String uid) => memberUids.contains(uid);

  CommunityGroup copyWith({int? memberCount, List<String>? memberUids}) =>
      CommunityGroup(
        id: id,
        name: name,
        description: description,
        avatarId: avatarId,
        memberCount: memberCount ?? this.memberCount,
        memberUids: memberUids ?? this.memberUids,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'avatarId': avatarId,
    'memberCount': memberCount,
    'memberUids': memberUids,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
  };

  static CommunityGroup fromMap(String id, Map<String, dynamic> m) =>
      CommunityGroup(
        id: id,
        name: m['name'] as String? ?? '',
        description: m['description'] as String? ?? '',
        avatarId: m['avatarId'] as int? ?? 1,
        memberCount: m['memberCount'] as int? ?? 0,
        memberUids:
            (m['memberUids'] as List<dynamic>?)?.cast<String>() ?? const [],
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          m['createdAtMs'] as int? ?? 0,
        ),
      );

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    avatarId,
    memberCount,
    memberUids,
    createdAt,
  ];
}
