import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_page_state.dart';

/// Drives the new illustrated home page (mock data, local-only state).
class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit() : super(const HomePageState());

  /// Optimistically toggles a plan item's completion.
  void togglePlanItem(int index) {
    final items = [...state.planItems];
    items[index] = items[index].copyWith(done: !items[index].done);
    emit(state.copyWith(planItems: items));
  }

  /// Reorders a plan item (drag-and-drop). Uses ReorderableListView indices.
  void reorderPlanItem(int oldIndex, int newIndex) {
    final items = [...state.planItems];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    emit(state.copyWith(planItems: items));
  }
}
