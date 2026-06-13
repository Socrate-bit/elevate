import 'package:flutter_bloc/flutter_bloc.dart';

import '../../subscription/services/analytics_service.dart';
import 'tools_page_state.dart';

/// Drives the tools page (mock data, local-only state).
class ToolsPageCubit extends Cubit<ToolsPageState> {
  ToolsPageCubit() : super(const ToolsPageState());

  static const _tabNames = ['home', 'chat', 'journal', 'tools', 'community'];

  /// Selects a bottom-nav tab. Updates the highlight and logs analytics; the
  /// screen handles navigation between linked pages.
  void selectTab(int index) {
    if (index == state.navIndex) return;
    emit(state.copyWith(navIndex: index));
    AnalyticsService.capture(AnalyticsService.navTabSelected, {
      'tab': _tabNames[index],
      'index': index,
    });
  }
}
