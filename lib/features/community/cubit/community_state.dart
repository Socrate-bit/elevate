import 'package:equatable/equatable.dart';

import '../models/community_mock_data.dart';

/// State of the Community page (mock data, local-only).
class CommunityState extends Equatable {
  final CommunitySegment segment;
  final CommunityFilter filter;
  final int? selectedMood;
  final List<CommunityPost> posts;

  const CommunityState({
    this.segment = CommunitySegment.feed,
    this.filter = CommunityFilter.forYou,
    this.selectedMood,
    this.posts = CommunityMockData.posts,
  });

  CommunityState copyWith({
    CommunitySegment? segment,
    CommunityFilter? filter,
    int? selectedMood,
    List<CommunityPost>? posts,
  }) => CommunityState(
    segment: segment ?? this.segment,
    filter: filter ?? this.filter,
    selectedMood: selectedMood ?? this.selectedMood,
    posts: posts ?? this.posts,
  );

  @override
  List<Object?> get props => [segment, filter, selectedMood, posts];
}
