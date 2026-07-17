import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../subscription/services/analytics_service.dart';
import '../models/community_comment.dart';
import '../models/community_profile.dart';
import '../services/community_firestore_service.dart';
import '../services/community_repository.dart';
import 'community_post_detail_state.dart';

/// Owns the live comment thread for a single post.
class CommunityPostDetailCubit extends Cubit<CommunityPostDetailState> {
  CommunityPostDetailCubit(
    this.postId, {
    CommunityRepository? repository,
    Uuid? uuid,
  }) : _repo = repository ?? CommunityFirestoreService.instance,
       _uuid = uuid ?? const Uuid(),
       super(const CommunityPostDetailState()) {
    _subscribe();
  }

  final String postId;
  final CommunityRepository _repo;
  final Uuid _uuid;
  StreamSubscription? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo.watchComments(postId).listen(
      (comments) => emit(state.copyWith(comments: comments, isLoading: false)),
      onError: (e) {
        debugPrint('[CommunityPostDetailCubit] watchComments error: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  /// Adds a comment authored by [author]. The parent post's comment count is
  /// incremented by the repository.
  Future<void> addComment(CommunityProfile author, String body) async {
    if (body.trim().isEmpty) return;
    final comment = CommunityComment(
      id: _uuid.v4(),
      authorUid: author.uid,
      authorUsername: author.username,
      authorAvatarId: author.avatarId,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    try {
      await _repo.addComment(postId, comment);
      AnalyticsService.capture(AnalyticsService.communityCommentAdded);
    } catch (e) {
      debugPrint('[CommunityPostDetailCubit] addComment failed: $e');
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
