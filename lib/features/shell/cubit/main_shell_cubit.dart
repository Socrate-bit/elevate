import 'package:flutter_bloc/flutter_bloc.dart';

import '../../subscription/services/analytics_service.dart';
import 'main_shell_state.dart';

/// Drives the root navigation shell. Home (tab 0) and Community (tab 4) map to
/// real pages; the other tabs only update the highlight (selection-only).
class MainShellCubit extends Cubit<MainShellState> {
  MainShellCubit() : super(const MainShellState());

  static const _tabNames = ['home', 'chat', 'journal', 'tools', 'community'];

  // Tabs that map to a page in the shell's IndexedStack.
  static const _tabToPage = {0: 0, 4: 1};

  /// Selects a bottom-nav tab. Switches the visible page for Home/Community;
  /// other tabs keep the current page and only move the highlight.
  void selectTab(int index) {
    if (index == state.selectedTab) return;
    emit(
      state.copyWith(
        selectedTab: index,
        pageIndex: _tabToPage[index] ?? state.pageIndex,
      ),
    );
    AnalyticsService.capture(AnalyticsService.navTabSelected, {
      'tab': _tabNames[index],
      'index': index,
    });
  }
}
