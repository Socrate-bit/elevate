import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../auth/auth_service.dart';
import '../../subscription/services/analytics_service.dart';
import '../models/community_conversation.dart';
import '../models/community_enums.dart';
import '../models/community_group.dart';
import '../models/community_post.dart';
import '../models/community_profile.dart';
import '../models/community_seed.dart';
import '../services/community_firestore_service.dart';
import '../services/community_repository.dart';
import 'community_state.dart';

/// Drives the Community page: live feed, groups, conversations and the current
/// user's profile. Subscribes on sign-in via [start] and tears down via
/// [clear] — mirroring the chat feature's lifecycle.
class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit({CommunityRepository? repository, Uuid? uuid})
    : _repo = repository ?? CommunityFirestoreService.instance,
      _uuid = uuid ?? const Uuid(),
      super(const CommunityState());

  final CommunityRepository _repo;
  final Uuid _uuid;

  StreamSubscription? _profileSub;
  StreamSubscription? _feedSub;
  StreamSubscription? _groupsSub;
  StreamSubscription? _convSub;

  /// Subscribes to all community streams for the current user. Call when auth
  /// flips to signed-in.
  void start() {
    final uid = AuthService.uidOrNull;
    if (uid == null) return;
    emit(state.copyWith(currentUid: uid, isLoading: true));

    // Seed the initial groups once (no-op if the collection already exists).
    _repo
        .seedGroupsIfEmpty(_seedGroups())
        .catchError((e) => debugPrint('[CommunityCubit] seed groups failed: $e'));

    _profileSub?.cancel();
    _profileSub = _repo.watchProfile(uid).listen(
      (profile) {
        if (profile != null) {
          emit(state.copyWith(profile: profile, needsProfile: false));
        } else {
          emit(state.copyWith(needsProfile: true));
        }
      },
      onError: (e) => debugPrint('[CommunityCubit] watchProfile error: $e'),
    );

    _feedSub?.cancel();
    _feedSub = _repo.watchFeed().listen(
      (posts) => emit(state.copyWith(posts: posts, isLoading: false)),
      onError: (e) {
        debugPrint('[CommunityCubit] watchFeed error: $e');
        emit(state.copyWith(isLoading: false));
      },
    );

    _groupsSub?.cancel();
    _groupsSub = _repo.watchGroups().listen(
      (groups) => emit(state.copyWith(groups: groups)),
      onError: (e) => debugPrint('[CommunityCubit] watchGroups error: $e'),
    );

    _convSub?.cancel();
    _convSub = _repo.watchConversations(uid).listen(
      (conversations) => emit(state.copyWith(conversations: conversations)),
      onError: (e) =>
          debugPrint('[CommunityCubit] watchConversations error: $e'),
    );
  }

  /// Cancels all streams and clears local state on sign-out.
  void clear() {
    _profileSub?.cancel();
    _feedSub?.cancel();
    _groupsSub?.cancel();
    _convSub?.cancel();
    _profileSub = _feedSub = _groupsSub = _convSub = null;
    emit(const CommunityState());
  }

  List<CommunityGroup> _seedGroups() => [
    for (final s in CommunitySeed.groups)
      CommunityGroup(
        id: s.id,
        name: s.name,
        description: s.description,
        avatarId: s.avatarId,
        memberCount: s.memberCount,
        createdAt: DateTime.now(),
      ),
  ];

  // ---- Segments / filters / check-in -------------------------------------

  void selectSegment(CommunitySegment segment) {
    if (segment == state.segment) return;
    emit(state.copyWith(segment: segment));
    AnalyticsService.capture(AnalyticsService.communitySegmentSelected, {
      'segment': segment.name,
    });
  }

  void selectFilter(CommunityFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  void selectMood(int index) {
    emit(state.copyWith(selectedMood: index));
    AnalyticsService.capture(AnalyticsService.moodRecorded, {
      'mood': index,
      'source': 'community_check_in',
    });
  }

  // ---- Profile -----------------------------------------------------------

  /// Creates (or updates) the current user's community profile. Used by the
  /// fallback gate for users who onboarded before profiles existed.
  Future<void> createProfile(String username) async {
    final uid = state.currentUid ?? AuthService.uidOrNull;
    if (uid == null || username.trim().isEmpty) return;
    final profile = CommunityProfile(
      uid: uid,
      username: username.trim(),
      avatarId: CommunityProfile.avatarIdForUid(uid),
      createdAt: DateTime.now(),
    );
    emit(state.copyWith(profile: profile, needsProfile: false));
    try {
      await _repo.setProfile(profile);
      debugPrint('[CommunityCubit] created profile for $uid');
      AnalyticsService.capture(AnalyticsService.communityProfileCreated);
    } catch (e) {
      debugPrint('[CommunityCubit] createProfile failed: $e');
    }
  }

  // ---- Feed actions ------------------------------------------------------

  /// Publishes a new post authored by the current user.
  Future<void> createPost({required String tag, required String body}) async {
    final profile = state.profile;
    if (profile == null || body.trim().isEmpty) return;
    final post = CommunityPost(
      id: _uuid.v4(),
      authorUid: profile.uid,
      authorUsername: profile.username,
      authorAvatarId: profile.avatarId,
      tag: tag,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    try {
      await _repo.createPost(post);
      debugPrint('[CommunityCubit] created post ${post.id}');
      AnalyticsService.capture(AnalyticsService.communityPostCreated, {
        'tag': tag,
      });
    } catch (e) {
      debugPrint('[CommunityCubit] createPost failed: $e');
    }
  }

  /// Optimistically toggles a post like and persists it.
  Future<void> toggleLike(CommunityPost post) async {
    final uid = state.currentUid;
    if (uid == null) return;
    final liked = !post.likedByMe(uid);
    final updated = post.copyWith(
      likedBy: liked
          ? [...post.likedBy, uid]
          : post.likedBy.where((u) => u != uid).toList(),
      likeCount: post.likeCount + (liked ? 1 : -1),
    );
    emit(state.copyWith(posts: _replacePost(updated)));
    try {
      await _repo.setLiked(post.id, uid, liked);
      AnalyticsService.capture(AnalyticsService.communityPostLiked, {
        'liked': liked,
      });
    } catch (e) {
      debugPrint('[CommunityCubit] toggleLike failed: $e');
      emit(state.copyWith(posts: _replacePost(post))); // rollback
    }
  }

  /// Optimistically bumps a post's share count.
  Future<void> sharePost(CommunityPost post) async {
    final updated = post.copyWith(shareCount: post.shareCount + 1);
    emit(state.copyWith(posts: _replacePost(updated)));
    try {
      await _repo.incrementShare(post.id);
    } catch (e) {
      debugPrint('[CommunityCubit] sharePost failed: $e');
      emit(state.copyWith(posts: _replacePost(post))); // rollback
    }
  }

  List<CommunityPost> _replacePost(CommunityPost p) =>
      state.posts.map((e) => e.id == p.id ? p : e).toList();

  // ---- Group actions -----------------------------------------------------

  /// Optimistically joins/leaves a group and persists membership.
  Future<void> setJoined(CommunityGroup group, bool joined) async {
    final uid = state.currentUid;
    if (uid == null) return;
    final updated = group.copyWith(
      memberUids: joined
          ? [...group.memberUids, uid]
          : group.memberUids.where((u) => u != uid).toList(),
      memberCount: group.memberCount + (joined ? 1 : -1),
    );
    emit(state.copyWith(groups: _replaceGroup(updated)));
    try {
      await _repo.setJoined(group.id, uid, joined);
      AnalyticsService.capture(AnalyticsService.communityGroupJoined, {
        'joined': joined,
      });
    } catch (e) {
      debugPrint('[CommunityCubit] setJoined failed: $e');
      emit(state.copyWith(groups: _replaceGroup(group))); // rollback
    }
  }

  List<CommunityGroup> _replaceGroup(CommunityGroup g) =>
      state.groups.map((e) => e.id == g.id ? g : e).toList();

  // ---- Messaging ---------------------------------------------------------

  /// Opens (creating if needed) the 1:1 conversation with [other], returning
  /// the conversation so the caller can navigate to it. Returns null if the
  /// current user has no profile or the write fails.
  Future<CommunityConversation?> openConversationWith(
    CommunityProfile other,
  ) async {
    final me = state.profile;
    if (me == null) return null;
    try {
      return await _repo.openConversation(me, other);
    } catch (e) {
      debugPrint('[CommunityCubit] openConversationWith failed: $e');
      return null;
    }
  }

  @override
  Future<void> close() {
    _profileSub?.cancel();
    _feedSub?.cancel();
    _groupsSub?.cancel();
    _convSub?.cancel();
    return super.close();
  }
}
