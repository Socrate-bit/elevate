import '../models/community_comment.dart';
import '../models/community_conversation.dart';
import '../models/community_dm_message.dart';
import '../models/community_group.dart';
import '../models/community_post.dart';
import '../models/community_profile.dart';

/// Repository surface for community persistence. Cubits depend on this so tests
/// can substitute an in-memory implementation. The Firestore-backed impl lives
/// in [CommunityFirestoreService].
///
/// Data lives in shared top-level collections (`community_posts`,
/// `community_groups`, `community_conversations`, `community_profiles`) — unlike
/// the app's per-user features under `users/{uid}/...`.
abstract interface class CommunityRepository {
  // Profiles.
  Stream<CommunityProfile?> watchProfile(String uid);
  Future<CommunityProfile?> getProfile(String uid);
  Future<void> setProfile(CommunityProfile profile);
  Future<List<CommunityProfile>> searchProfiles(String query, {int limit});

  // Feed.
  Stream<List<CommunityPost>> watchFeed({int limit});
  Future<void> createPost(CommunityPost post);
  Future<void> setLiked(String postId, String uid, bool liked);
  Future<void> incrementShare(String postId);

  // Comments.
  Stream<List<CommunityComment>> watchComments(String postId);
  Future<void> addComment(String postId, CommunityComment comment);

  // Groups.
  Stream<List<CommunityGroup>> watchGroups();
  Future<void> setJoined(String groupId, String uid, bool joined);
  Future<void> seedGroupsIfEmpty(Iterable<CommunityGroup> groups);

  // Direct messages.
  Stream<List<CommunityConversation>> watchConversations(String uid);
  Future<CommunityConversation> openConversation(
    CommunityProfile me,
    CommunityProfile other,
  );
  Stream<List<CommunityDmMessage>> watchMessages(String conversationId);
  Future<void> sendMessage(
    CommunityConversation conversation,
    CommunityDmMessage message,
    String recipientUid,
  );
  Future<void> markRead(String conversationId, String uid);
}
