import 'package:equatable/equatable.dart';

import '../models/community_comment.dart';

/// State for a single post's comment thread.
class CommunityPostDetailState extends Equatable {
  final List<CommunityComment> comments;
  final bool isLoading;

  const CommunityPostDetailState({
    this.comments = const [],
    this.isLoading = true,
  });

  CommunityPostDetailState copyWith({
    List<CommunityComment>? comments,
    bool? isLoading,
  }) => CommunityPostDetailState(
    comments: comments ?? this.comments,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [comments, isLoading];
}
