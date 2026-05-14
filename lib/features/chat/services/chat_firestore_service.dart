import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/auth_service.dart';
import 'chat_conversation.dart';
import 'chat_message.dart';

/// Repository surface for chat persistence. Cubits depend on this so tests
/// can substitute an in-memory implementation. The Firestore-backed impl
/// lives in [ChatFirestoreService].
abstract interface class ChatRepository {
  Stream<List<ChatConversation>> watchConversations();
  Stream<List<ChatMessage>> watchMessages(String conversationId);
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<void> saveConversation(ChatConversation c);
  Future<void> updateConversation(
    String id, {
    String? title,
    DateTime? lastMessageAt,
    String? summary,
    DateTime? summaryAt,
    bool? memoryExtracted,
  });
  Future<void> deleteConversation(String id);
  Future<void> saveMessage(ChatMessage m);
  Future<void> updateMessageForm(
    String conversationId,
    String messageId,
    int selectedIndex,
  );

  Future<void> updateMessageMissionSuggestion(
    String conversationId,
    String messageId,
    bool accepted,
  );

  Future<void> updateMessageMoodCheckIn(
    String conversationId,
    String messageId,
    String selectedMood,
  );
}

/// Firestore-backed [ChatRepository].
/// Layout:  users/{uid}/conversations/{cid}  +  .../messages/{mid}
class ChatFirestoreService implements ChatRepository {
  const ChatFirestoreService();

  /// Default singleton used by production code.
  static const ChatRepository instance = ChatFirestoreService();

  CollectionReference<Map<String, dynamic>> _conversations() =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.uid)
          .collection('conversations');

  CollectionReference<Map<String, dynamic>> _messages(String cid) =>
      _conversations().doc(cid).collection('messages');

  @override
  Stream<List<ChatConversation>> watchConversations() {
    return _conversations()
        .orderBy('lastMessageAtMs', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatConversation.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _messages(conversationId)
        .orderBy('createdAtMs')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatMessage.fromMap(d.id, conversationId, d.data()))
              .toList(),
        );
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final snap =
        await _messages(conversationId).orderBy('createdAtMs').get();
    return snap.docs
        .map((d) => ChatMessage.fromMap(d.id, conversationId, d.data()))
        .toList();
  }

  @override
  Future<void> saveConversation(ChatConversation c) =>
      _conversations().doc(c.id).set(c.toMap());

  @override
  Future<void> updateConversation(
    String id, {
    String? title,
    DateTime? lastMessageAt,
    String? summary,
    DateTime? summaryAt,
    bool? memoryExtracted,
  }) {
    final patch = <String, dynamic>{};
    if (title != null) patch['title'] = title;
    if (lastMessageAt != null) {
      patch['lastMessageAtMs'] = lastMessageAt.millisecondsSinceEpoch;
    }
    if (summary != null) patch['summary'] = summary;
    if (summaryAt != null) {
      patch['summaryAtMs'] = summaryAt.millisecondsSinceEpoch;
    }
    if (memoryExtracted != null) patch['memoryExtracted'] = memoryExtracted;
    if (patch.isEmpty) return Future.value();
    return _conversations().doc(id).update(patch);
  }

  @override
  Future<void> deleteConversation(String id) async {
    final messages = await _messages(id).get();
    for (final doc in messages.docs) {
      await doc.reference.delete();
    }
    await _conversations().doc(id).delete();
  }

  @override
  Future<void> saveMessage(ChatMessage m) =>
      _messages(m.conversationId).doc(m.id).set(m.toMap());

  @override
  Future<void> updateMessageForm(
    String conversationId,
    String messageId,
    int selectedIndex,
  ) =>
      _messages(conversationId).doc(messageId).update({
        'form.selectedIndex': selectedIndex,
      });

  @override
  Future<void> updateMessageMissionSuggestion(
    String conversationId,
    String messageId,
    bool accepted,
  ) =>
      _messages(conversationId).doc(messageId).update({
        'missionSuggestion.accepted': accepted,
      });

  @override
  Future<void> updateMessageMoodCheckIn(
    String conversationId,
    String messageId,
    String selectedMood,
  ) =>
      _messages(conversationId).doc(messageId).update({
        'moodCheckIn.selectedMood': selectedMood,
      });
}
