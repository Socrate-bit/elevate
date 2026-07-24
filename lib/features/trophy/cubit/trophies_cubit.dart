import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/trophy.dart';
import '../services/trophy_service.dart';
import 'trophies_state.dart';

/// Streams the user's earned trophies (newest first) for the gallery grid.
class TrophiesCubit extends Cubit<TrophiesState> {
  TrophiesCubit() : super(const TrophiesState());

  StreamSubscription<List<Trophy>>? _sub;

  void start() {
    _sub?.cancel();
    _sub = TrophyService.watchTrophies().listen(
      (trophies) {
        if (isClosed) return;
        emit(state.copyWith(trophies: trophies, isLoading: false));
      },
      onError: (e) {
        debugPrint('[TrophiesCubit] watch failed: $e');
        if (isClosed) return;
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
