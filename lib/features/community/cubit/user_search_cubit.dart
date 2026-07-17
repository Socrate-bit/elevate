import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/community_firestore_service.dart';
import '../services/community_repository.dart';
import 'user_search_state.dart';

/// Debounced username-prefix search over community profiles.
class UserSearchCubit extends Cubit<UserSearchState> {
  UserSearchCubit({CommunityRepository? repository, this.excludeUid})
    : _repo = repository ?? CommunityFirestoreService.instance,
      super(const UserSearchState());

  final CommunityRepository _repo;

  /// Uid to omit from results (typically the current user).
  final String? excludeUid;
  Timer? _debounce;

  void search(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _run(query));
  }

  Future<void> _run(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(results: const [], isSearching: false));
      return;
    }
    emit(state.copyWith(isSearching: true));
    try {
      final results = await _repo.searchProfiles(query);
      emit(
        state.copyWith(
          results: results.where((p) => p.uid != excludeUid).toList(),
          isSearching: false,
        ),
      );
    } catch (e) {
      debugPrint('[UserSearchCubit] search failed: $e');
      emit(state.copyWith(isSearching: false));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
