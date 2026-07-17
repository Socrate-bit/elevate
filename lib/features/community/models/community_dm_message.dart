import 'package:equatable/equatable.dart';

/// A single direct message inside a conversation. Stored at
/// `community_conversations/{conversationId}/messages/{id}`.
class CommunityDmMessage extends Equatable {
  final String id;
  final String senderUid;
  final String body;
  final DateTime createdAt;

  const CommunityDmMessage({
    required this.id,
    required this.senderUid,
    required this.body,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'senderUid': senderUid,
    'body': body,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
  };

  static CommunityDmMessage fromMap(String id, Map<String, dynamic> m) =>
      CommunityDmMessage(
        id: id,
        senderUid: m['senderUid'] as String? ?? '',
        body: m['body'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          m['createdAtMs'] as int? ?? 0,
        ),
      );

  @override
  List<Object?> get props => [id, senderUid, body, createdAt];
}
