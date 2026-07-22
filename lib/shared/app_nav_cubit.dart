import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/subscription/services/analytics_service.dart';

/// Holds the selected bottom-nav tab index, shared across the Appy pages
/// (Home, Chat, …) so a single nav bar can drive the [AppyShell].
class AppNavCubit extends Cubit<int> {
  AppNavCubit() : super(0);

  static const _tabNames = ['home', 'quest', 'journal'];

  /// Selects a bottom-nav tab (Home 0, Quest 1, Journal 2).
  void selectTab(int index) {
    if (index == state) return;
    emit(index);
    AnalyticsService.capture(AnalyticsService.navTabSelected, {
      'tab': _tabNames[index],
      'index': index,
    });
  }
}
