import 'package:flutter_bloc/flutter_bloc.dart';

import '../../subscription/services/analytics_service.dart';
import 'journal_state.dart';

/// Drives the Journal page (mock data, local-only state).
class JournalCubit extends Cubit<JournalState> {
  JournalCubit() : super(const JournalState());

  static const _tabNames = ['home', 'chat', 'journal', 'tools', 'community'];

  /// Selects a bottom-nav tab. Page routing (Home/Journal) is handled by the
  /// screen — this only tracks selection and reports analytics.
  void selectTab(int index) {
    if (index == state.navIndex) return;
    emit(state.copyWith(navIndex: index));
    AnalyticsService.capture(AnalyticsService.navTabSelected, {
      'tab': _tabNames[index],
      'index': index,
    });
  }
}
