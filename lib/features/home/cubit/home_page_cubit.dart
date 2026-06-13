import 'package:flutter_bloc/flutter_bloc.dart';

import '../../subscription/services/analytics_service.dart';
import 'home_page_state.dart';

/// Drives the new illustrated home page (mock data, local-only state).
class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit() : super(const HomePageState());

  static const _tabNames = ['home', 'chat', 'journal', 'tools', 'community'];

  /// Selects a bottom-nav tab. Pages are not linked yet — selection only.
  void selectTab(int index) {
    if (index == state.navIndex) return;
    emit(state.copyWith(navIndex: index));
    AnalyticsService.capture(AnalyticsService.navTabSelected, {
      'tab': _tabNames[index],
      'index': index,
    });
  }

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
