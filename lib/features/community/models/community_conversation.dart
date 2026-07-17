import 'package:equatable/equatable.dart';

import 'community_profile.dart';

/// A 1:1 direct-message conversation preview. Stored at
/// `community_conversations/{conversationId}` where the id is the two uids
/// sorted and joined (`a_b`) so a pair maps to exactly one document.
/// Messages live in a `messages` subcollection. Participant identities and
/// per-user unread counts are denormalized onto the doc.
class CommunityConversation extends Equatable {
  final String id;
  final List<String> participantUids;
  final Map<String, String> usernames; // uid -> username
  final Map<String, int> avatarIds; // uid -> avatarId
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCounts; // uid -> unread count

  const CommunityConversation({
    required this.id,
    required this.participantUids,
    required this.usernames,
    required this.avatarIds,
    this.lastMessage = '',
    required this.lastMessageAt,
    this.unreadCounts = const {},
  });

  /// Deterministic conversation id for a pair of uids.
  static String idFor(String a, String b) => ([a, b]..sort()).join('_');

  String otherUid(String currentUid) => participantUids.firstWhere(
    (u) => u != currentUid,
    orElse: () => currentUid,
  );

  String usernameFor(String uid) => usernames[uid] ?? '';
  int avatarIdFor(String uid) => avatarIds[uid] ?? 1;
  String avatarAssetFor(String uid) =>
      CommunityProfile.avatarAssetFor(avatarIdFor(uid));
  int unreadFor(String uid) => unreadCounts[uid] ?? 0;

  Map<String, dynamic> toMap() => {
    'participantUids': participantUids,
    'usernames': usernames,
    'avatarIds': avatarIds,
    'lastMessage': lastMessage,
    'lastMessageAtMs': lastMessageAt.millisecondsSinceEpoch,
    'unreadCounts': unreadCounts,
  };

  static CommunityConversation fromMap(String id, Map<String, dynamic> m) =>
      CommunityConversation(
        id: id,
        participantUids:
            (m['participantUids'] as List<dynamic>?)?.cast<String>() ??
            const [],
        usernames:
            (m['usernames'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as String? ?? ''),
            ) ??
            const {},
        avatarIds:
            (m['avatarIds'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 1),
            ) ??
            const {},
        lastMessage: m['lastMessage'] as String? ?? '',
        lastMessageAt: DateTime.fromMillisecondsSinceEpoch(
          m['lastMessageAtMs'] as int? ?? 0,
        ),
        unreadCounts:
            (m['unreadCounts'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
            ) ??
            const {},
      );

  @override
  List<Object?> get props => [
    id,
    participantUids,
    usernames,
    avatarIds,
    lastMessage,
    lastMessageAt,
    unreadCounts,
  ];
}
