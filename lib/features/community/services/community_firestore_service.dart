import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community_comment.dart';
import '../models/community_conversation.dart';
import '../models/community_dm_message.dart';
import '../models/community_group.dart';
import '../models/community_post.dart';
import '../models/community_profile.dart';
import 'community_repository.dart';

/// Firestore-backed [CommunityRepository].
///
/// Layout (shared, top-level):
///   community_profiles/{uid}
///   community_posts/{postId}            + .../comments/{commentId}
///   community_groups/{groupId}
///   community_conversations/{cid}       + .../messages/{messageId}
class CommunityFirestoreService implements CommunityRepository {
  const CommunityFirestoreService();

  /// Default singleton used by production code.
  static const CommunityRepository instance = CommunityFirestoreService();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _db.collection('community_profiles');
  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('community_posts');
  CollectionReference<Map<String, dynamic>> _comments(String postId) =>
      _posts.doc(postId).collection('comments');
  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('community_groups');
  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('community_conversations');
  CollectionReference<Map<String, dynamic>> _messages(String cid) =>
      _conversations.doc(cid).collection('messages');

  // ---- Profiles ----------------------------------------------------------

  @override
  Stream<CommunityProfile?> watchProfile(String uid) => _profiles
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? CommunityProfile.fromMap(d.id, d.data()!) : null);

  @override
  Future<CommunityProfile?> getProfile(String uid) async {
    final d = await _profiles.doc(uid).get();
    return d.exists ? CommunityProfile.fromMap(d.id, d.data()!) : null;
  }

  @override
  Future<void> setProfile(CommunityProfile profile) =>
      _profiles.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));

  @override
  Future<List<CommunityProfile>> searchProfiles(
    String query, {
    int limit = 20,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    // Prefix range query on the lowercased username.
    final snap = await _profiles
        .orderBy('usernameLower')
        .startAt([q])
        .endAt(['$q'])
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => CommunityProfile.fromMap(d.id, d.data()))
        .toList();
  }

  // ---- Feed --------------------------------------------------------------

  @override
  Stream<List<CommunityPost>> watchFeed({int limit = 100}) => _posts
      .orderBy('createdAtMs', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => CommunityPost.fromMap(d.id, d.data())).toList(),
      );

  @override
  Future<void> createPost(CommunityPost post) =>
      _posts.doc(post.id).set(post.toMap());

  @override
  Future<void> setLiked(String postId, String uid, bool liked) =>
      _posts.doc(postId).update({
        'likedBy': liked
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
        'likeCount': FieldValue.increment(liked ? 1 : -1),
      });

  @override
  Future<void> incrementShare(String postId) =>
      _posts.doc(postId).update({'shareCount': FieldValue.increment(1)});

  // ---- Comments ----------------------------------------------------------

  @override
  Stream<List<CommunityComment>> watchComments(String postId) =>
      _comments(postId).orderBy('createdAtMs').snapshots().map(
        (snap) => snap.docs
            .map((d) => CommunityComment.fromMap(d.id, d.data()))
            .toList(),
      );

  @override
  Future<void> addComment(String postId, CommunityComment comment) async {
    final batch = _db.batch();
    batch.set(_comments(postId).doc(comment.id), comment.toMap());
    batch.update(_posts.doc(postId), {
      'commentCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  // ---- Groups ------------------------------------------------------------

  @override
  Stream<List<CommunityGroup>> watchGroups() => _groups
      .orderBy('memberCount', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => CommunityGroup.fromMap(d.id, d.data()))
            .toList(),
      );

  @override
  Future<void> setJoined(String groupId, String uid, bool joined) =>
      _groups.doc(groupId).update({
        'memberUids': joined
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
        'memberCount': FieldValue.increment(joined ? 1 : -1),
      });

  @override
  Future<void> seedGroupsIfEmpty(Iterable<CommunityGroup> groups) async {
    final existing = await _groups.limit(1).get();
    if (existing.docs.isNotEmpty) return;
    final batch = _db.batch();
    for (final g in groups) {
      batch.set(_groups.doc(g.id), g.toMap());
    }
    await batch.commit();
  }

  // ---- Direct messages ---------------------------------------------------

  @override
  Stream<List<CommunityConversation>> watchConversations(String uid) =>
      _conversations
          .where('participantUids', arrayContains: uid)
          .orderBy('lastMessageAtMs', descending: true)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => CommunityConversation.fromMap(d.id, d.data()))
                .toList(),
          );

  @override
  Future<CommunityConversation> openConversation(
    CommunityProfile me,
    CommunityProfile other,
  ) async {
    final id = CommunityConversation.idFor(me.uid, other.uid);
    final ref = _conversations.doc(id);
    final snap = await ref.get();
    if (snap.exists) return CommunityConversation.fromMap(id, snap.data()!);
    final conv = CommunityConversation(
      id: id,
      participantUids: [me.uid, other.uid],
      usernames: {me.uid: me.username, other.uid: other.username},
      avatarIds: {me.uid: me.avatarId, other.uid: other.avatarId},
      lastMessageAt: DateTime.now(),
      unreadCounts: {me.uid: 0, other.uid: 0},
    );
    await ref.set(conv.toMap());
    return conv;
  }

  @override
  Stream<List<CommunityDmMessage>> watchMessages(String conversationId) =>
      _messages(conversationId).orderBy('createdAtMs').snapshots().map(
        (snap) => snap.docs
            .map((d) => CommunityDmMessage.fromMap(d.id, d.data()))
            .toList(),
      );

  @override
  Future<void> sendMessage(
    CommunityConversation conversation,
    CommunityDmMessage message,
    String recipientUid,
  ) async {
    final batch = _db.batch();
    batch.set(_messages(conversation.id).doc(message.id), message.toMap());
    // Conversation doc always exists (created by openConversation) so update
    // can bump the nested unread counter for the recipient.
    batch.update(_conversations.doc(conversation.id), {
      'lastMessage': message.body,
      'lastMessageAtMs': message.createdAt.millisecondsSinceEpoch,
      'unreadCounts.$recipientUid': FieldValue.increment(1),
    });
    await batch.commit();
  }

  @override
  Future<void> markRead(String conversationId, String uid) =>
      _conversations.doc(conversationId).update({'unreadCounts.$uid': 0});
}
