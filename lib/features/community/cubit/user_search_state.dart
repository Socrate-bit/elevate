import 'package:equatable/equatable.dart';

import '../models/community_profile.dart';

/// State for the searchable user picker (new-message flow).
class UserSearchState extends Equatable {
  final String query;
  final List<CommunityProfile> results;
  final bool isSearching;

  const UserSearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
  });

  UserSearchState copyWith({
    String? query,
    List<CommunityProfile>? results,
    bool? isSearching,
  }) => UserSearchState(
    query: query ?? this.query,
    results: results ?? this.results,
    isSearching: isSearching ?? this.isSearching,
  );

  @override
  List<Object?> get props => [query, results, isSearching];
}
