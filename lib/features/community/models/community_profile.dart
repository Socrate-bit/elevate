import 'package:equatable/equatable.dart';

/// A user's public community identity: a chosen username + an auto-assigned
/// preset avatar (deterministic from uid). Stored at `community_profiles/{uid}`.
class CommunityProfile extends Equatable {
  final String uid;
  final String username;

  /// Preset avatar id, 1..4. Assigned deterministically from the uid.
  final int avatarId;
  final DateTime createdAt;

  const CommunityProfile({
    required this.uid,
    required this.username,
    required this.avatarId,
    required this.createdAt,
  });

  /// Preset avatar asset for an avatar id (1..4).
  /// Note: id 2 maps to the misspelled `Avater2.png` asset on disk.
  static String avatarAssetFor(int avatarId) {
    switch (avatarId) {
      case 2:
        return 'assets/community/profil_avatar/Avater2.png';
      case 3:
        return 'assets/community/profil_avatar/Avatar3.png';
      case 4:
        return 'assets/community/profil_avatar/Avatar4.png';
      case 1:
      default:
        return 'assets/community/profil_avatar/Avatar1.png';
    }
  }

  /// Deterministic preset avatar id (1..4) derived from a uid.
  static int avatarIdForUid(String uid) => uid.hashCode.abs() % 4 + 1;

  String get avatarAsset => avatarAssetFor(avatarId);

  Map<String, dynamic> toMap() => {
    'username': username,
    'usernameLower': username.toLowerCase(),
    'avatarId': avatarId,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
  };

  static CommunityProfile fromMap(String id, Map<String, dynamic> m) =>
      CommunityProfile(
        uid: id,
        username: m['username'] as String? ?? '',
        avatarId: m['avatarId'] as int? ?? avatarIdForUid(id),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          m['createdAtMs'] as int? ?? 0,
        ),
      );

  @override
  List<Object?> get props => [uid, username, avatarId, createdAt];
}
