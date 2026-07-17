import 'package:equatable/equatable.dart';

import '../models/community_conversation.dart';
import '../models/community_enums.dart';
import '../models/community_group.dart';
import '../models/community_post.dart';
import '../models/community_profile.dart';

/// State of the Community page. Feed/groups/conversations are live Firestore
/// data; [selectedMood] is a local-only check-in.
class CommunityState extends Equatable {
  final CommunitySegment segment;
  final CommunityFilter filter;
  final int? selectedMood;

  /// The signed-in user's uid (set on [start]).
  final String? currentUid;

  /// The signed-in user's community profile, or null if not yet created.
  final CommunityProfile? profile;

  /// True when signed in but no community profile exists yet — the page gates
  /// interaction behind a username-setup sheet.
  final bool needsProfile;

  final List<CommunityPost> posts;
  final List<CommunityGroup> groups;
  final List<CommunityConversation> conversations;
  final bool isLoading;

  const CommunityState({
    this.segment = CommunitySegment.feed,
    this.filter = CommunityFilter.forYou,
    this.selectedMood,
    this.currentUid,
    this.profile,
    this.needsProfile = false,
    this.posts = const [],
    this.groups = const [],
    this.conversations = const [],
    this.isLoading = false,
  });

  /// Posts ordered for the active filter. Feed arrives newest-first;
  /// "For you" surfaces the most-liked. Following/Support have no dedicated
  /// backend signal yet, so they fall back to the newest-first order.
  List<CommunityPost> get filteredPosts {
    switch (filter) {
      case CommunityFilter.forYou:
        return [...posts]..sort((a, b) => b.likeCount.compareTo(a.likeCount));
      case CommunityFilter.recent:
      case CommunityFilter.following:
      case CommunityFilter.support:
        return posts;
    }
  }

  /// Total unread direct messages for the current user.
  int get unreadTotal {
    final uid = currentUid;
    if (uid == null) return 0;
    return conversations.fold(0, (sum, c) => sum + c.unreadFor(uid));
  }

  CommunityState copyWith({
    CommunitySegment? segment,
    CommunityFilter? filter,
    int? selectedMood,
    String? currentUid,
    CommunityProfile? profile,
    bool? needsProfile,
    List<CommunityPost>? posts,
    List<CommunityGroup>? groups,
    List<CommunityConversation>? conversations,
    bool? isLoading,
  }) => CommunityState(
    segment: segment ?? this.segment,
    filter: filter ?? this.filter,
    selectedMood: selectedMood ?? this.selectedMood,
    currentUid: currentUid ?? this.currentUid,
    profile: profile ?? this.profile,
    needsProfile: needsProfile ?? this.needsProfile,
    posts: posts ?? this.posts,
    groups: groups ?? this.groups,
    conversations: conversations ?? this.conversations,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [
    segment,
    filter,
    selectedMood,
    currentUid,
    profile,
    needsProfile,
    posts,
    groups,
    conversations,
    isLoading,
  ];
}
