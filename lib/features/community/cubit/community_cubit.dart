import 'package:flutter_bloc/flutter_bloc.dart';

import '../../subscription/services/analytics_service.dart';
import '../models/community_mock_data.dart';
import 'community_state.dart';

/// Drives the Community page (mock data, local-only state).
class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit() : super(const CommunityState());

  /// Switches the top segment (Feed / Groups / Messages).
  void selectSegment(CommunitySegment segment) {
    if (segment == state.segment) return;
    emit(state.copyWith(segment: segment));
    AnalyticsService.capture(AnalyticsService.communitySegmentSelected, {
      'segment': segment.name,
    });
  }

  /// Selects a feed filter chip.
  void selectFilter(CommunityFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  /// Records the community check-in mood (index into [CommunityMockData.moodAssets]).
  void selectMood(int index) {
    emit(state.copyWith(selectedMood: index));
    AnalyticsService.capture(AnalyticsService.moodRecorded, {
      'mood': index,
      'source': 'community_check_in',
    });
  }

  /// Optimistically toggles a post's like.
  void toggleLike(int index) {
    final posts = [...state.posts];
    final post = posts[index];
    final liked = !post.liked;
    posts[index] = post.copyWith(
      liked: liked,
      likes: post.likes + (liked ? 1 : -1),
    );
    emit(state.copyWith(posts: posts));
    AnalyticsService.capture(AnalyticsService.communityPostLiked, {
      'liked': liked,
    });
  }
}
